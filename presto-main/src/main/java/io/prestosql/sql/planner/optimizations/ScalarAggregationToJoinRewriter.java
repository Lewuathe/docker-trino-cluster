/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package io.prestosql.sql.planner.optimizations;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import io.prestosql.metadata.FunctionRegistry;
import io.prestosql.spi.type.BigintType;
import io.prestosql.spi.type.BooleanType;
import io.prestosql.spi.type.TypeSignature;
import io.prestosql.sql.planner.PlanNodeIdAllocator;
import io.prestosql.sql.planner.Symbol;
import io.prestosql.sql.planner.SymbolAllocator;
import io.prestosql.sql.planner.iterative.Lookup;
import io.prestosql.sql.planner.optimizations.PlanNodeDecorrelator.DecorrelatedNode;
import io.prestosql.sql.planner.plan.AggregationNode;
import io.prestosql.sql.planner.plan.AggregationNode.Aggregation;
import io.prestosql.sql.planner.plan.AssignUniqueId;
import io.prestosql.sql.planner.plan.Assignments;
import io.prestosql.sql.planner.plan.EnforceSingleRowNode;
import io.prestosql.sql.planner.plan.JoinNode;
import io.prestosql.sql.planner.plan.LateralJoinNode;
import io.prestosql.sql.planner.plan.PlanNode;
import io.prestosql.sql.planner.plan.ProjectNode;
import io.prestosql.sql.tree.Expression;
import io.prestosql.sql.tree.FunctionCall;
import io.prestosql.sql.tree.QualifiedName;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

import static com.google.common.collect.ImmutableList.toImmutableList;
import static io.prestosql.sql.analyzer.TypeSignatureProvider.fromTypeSignatures;
import static io.prestosql.sql.planner.optimizations.PlanNodeSearcher.searchFrom;
import static io.prestosql.sql.planner.plan.AggregationNode.singleGroupingSet;
import static io.prestosql.sql.tree.BooleanLiteral.TRUE_LITERAL;
import static java.util.Objects.requireNonNull;

// TODO: move this class to TransformCorrelatedScalarAggregationToJoin when old optimizer is gone
public class ScalarAggregationToJoinRewriter
{
    private static final QualifiedName COUNT = QualifiedName.of("count");

    private final FunctionRegistry functionRegistry;
    private final SymbolAllocator symbolAllocator;
    private final PlanNodeIdAllocator idAllocator;
    private final Lookup lookup;
    private final PlanNodeDecorrelator planNodeDecorrelator;

    public ScalarAggregationToJoinRewriter(FunctionRegistry functionRegistry, SymbolAllocator symbolAllocator, PlanNodeIdAllocator idAllocator, Lookup lookup)
    {
        this.functionRegistry = requireNonNull(functionRegistry, "metadata is null");
        this.symbolAllocator = requireNonNull(symbolAllocator, "symbolAllocator is null");
        this.idAllocator = requireNonNull(idAllocator, "idAllocator is null");
        this.lookup = requireNonNull(lookup, "lookup is null");
        this.planNodeDecorrelator = new PlanNodeDecorrelator(idAllocator, lookup);
    }

    public PlanNode rewriteScalarAggregation(LateralJoinNode lateralJoinNode, AggregationNode aggregation)
    {
        List<Symbol> correlation = lateralJoinNode.getCorrelation();
        Optional<DecorrelatedNode> source = planNodeDecorrelator.decorrelateFilters(lookup.resolve(aggregation.getSource()), correlation);
        if (!source.isPresent()) {
            return lateralJoinNode;
        }

        Symbol nonNull = symbolAllocator.newSymbol("non_null", BooleanType.BOOLEAN);
        Assignments scalarAggregationSourceAssignments = Assignments.builder()
                .putIdentities(source.get().getNode().getOutputSymbols())
                .put(nonNull, TRUE_LITERAL)
                .build();
        ProjectNode scalarAggregationSourceWithNonNullableSymbol = new ProjectNode(
                idAllocator.getNextId(),
                source.get().getNode(),
                scalarAggregationSourceAssignments);

        return rewriteScalarAggregation(
                lateralJoinNode,
                aggregation,
                scalarAggregationSourceWithNonNullableSymbol,
                source.get().getCorrelatedPredicates(),
                nonNull);
    }

    private PlanNode rewriteScalarAggregation(
            LateralJoinNode lateralJoinNode,
            AggregationNode scalarAggregation,
            PlanNode scalarAggregationSource,
            Optional<Expression> joinExpression,
            Symbol nonNull)
    {
        AssignUniqueId inputWithUniqueColumns = new AssignUniqueId(
                idAllocator.getNextId(),
                lateralJoinNode.getInput(),
                symbolAllocator.newSymbol("unique", BigintType.BIGINT));

        JoinNode leftOuterJoin = new JoinNode(
                idAllocator.getNextId(),
                JoinNode.Type.LEFT,
                inputWithUniqueColumns,
                scalarAggregationSource,
                ImmutableList.of(),
                ImmutableList.<Symbol>builder()
                        .addAll(inputWithUniqueColumns.getOutputSymbols())
                        .addAll(scalarAggregationSource.getOutputSymbols())
                        .build(),
                joinExpression,
                Optional.empty(),
                Optional.empty(),
                Optional.empty());

        Optional<AggregationNode> aggregationNode = createAggregationNode(
                scalarAggregation,
                leftOuterJoin,
                nonNull);

        if (!aggregationNode.isPresent()) {
            return lateralJoinNode;
        }

        Optional<ProjectNode> subqueryProjection = searchFrom(lateralJoinNode.getSubquery(), lookup)
                .where(ProjectNode.class::isInstance)
                .recurseOnlyWhen(EnforceSingleRowNode.class::isInstance)
                .findFirst();

        List<Symbol> aggregationOutputSymbols = getTruncatedAggregationSymbols(lateralJoinNode, aggregationNode.get());

        if (subqueryProjection.isPresent()) {
            Assignments assignments = Assignments.builder()
                    .putIdentities(aggregationOutputSymbols)
                    .putAll(subqueryProjection.get().getAssignments())
                    .build();

            return new ProjectNode(
                    idAllocator.getNextId(),
                    aggregationNode.get(),
                    assignments);
        }
        else {
            return new ProjectNode(
                    idAllocator.getNextId(),
                    aggregationNode.get(),
                    Assignments.identity(aggregationOutputSymbols));
        }
    }

    private static List<Symbol> getTruncatedAggregationSymbols(LateralJoinNode lateralJoinNode, AggregationNode aggregationNode)
    {
        Set<Symbol> applySymbols = new HashSet<>(lateralJoinNode.getOutputSymbols());
        return aggregationNode.getOutputSymbols().stream()
                .filter(applySymbols::contains)
                .collect(toImmutableList());
    }

    private Optional<AggregationNode> createAggregationNode(
            AggregationNode scalarAggregation,
            JoinNode leftOuterJoin,
            Symbol nonNullableAggregationSourceSymbol)
    {
        ImmutableMap.Builder<Symbol, Aggregation> aggregations = ImmutableMap.builder();
        for (Map.Entry<Symbol, Aggregation> entry : scalarAggregation.getAggregations().entrySet()) {
            FunctionCall call = entry.getValue().getCall();
            Symbol symbol = entry.getKey();
            if (call.getName().equals(COUNT)) {
                List<TypeSignature> scalarAggregationSourceTypeSignatures = ImmutableList.of(
                        symbolAllocator.getTypes().get(nonNullableAggregationSourceSymbol).getTypeSignature());
                aggregations.put(symbol, new Aggregation(
                        new FunctionCall(
                                COUNT,
                                ImmutableList.of(nonNullableAggregationSourceSymbol.toSymbolReference())),
                        functionRegistry.resolveFunction(
                                COUNT,
                                fromTypeSignatures(scalarAggregationSourceTypeSignatures)),
                        entry.getValue().getMask()));
            }
            else {
                aggregations.put(symbol, entry.getValue());
            }
        }

        return Optional.of(new AggregationNode(
                idAllocator.getNextId(),
                leftOuterJoin,
                aggregations.build(),
                singleGroupingSet(leftOuterJoin.getLeft().getOutputSymbols()),
                ImmutableList.of(),
                scalarAggregation.getStep(),
                scalarAggregation.getHashSymbol(),
                Optional.empty()));
    }
}
