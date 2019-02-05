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
package io.prestosql.server;

import com.google.common.collect.ImmutableMap;
import io.airlift.configuration.testing.ConfigAssertions;
import io.airlift.units.Duration;
import io.prestosql.failureDetector.FailureDetectorConfig;
import org.testng.annotations.Test;

import java.util.Map;
import java.util.concurrent.TimeUnit;

public class TestFailureDetectorConfig
{
    @Test
    public void testDefaults()
    {
        ConfigAssertions.assertRecordedDefaults(ConfigAssertions.recordDefaults(FailureDetectorConfig.class)
                .setExpirationGraceInterval(new Duration(10, TimeUnit.MINUTES))
                .setFailureRatioThreshold(0.1)
                .setHeartbeatInterval(new Duration(500, TimeUnit.MILLISECONDS))
                .setWarmupInterval(new Duration(5, TimeUnit.SECONDS))
                .setEnabled(true));
    }

    @Test
    public void testExplicitPropertyMappings()
    {
        Map<String, String> properties = new ImmutableMap.Builder<String, String>()
                .put("failure-detector.expiration-grace-interval", "5m")
                .put("failure-detector.warmup-interval", "60s")
                .put("failure-detector.heartbeat-interval", "10s")
                .put("failure-detector.threshold", "0.5")
                .put("failure-detector.enabled", "false")
                .build();

        FailureDetectorConfig expected = new FailureDetectorConfig()
                .setExpirationGraceInterval(new Duration(5, TimeUnit.MINUTES))
                .setWarmupInterval(new Duration(60, TimeUnit.SECONDS))
                .setHeartbeatInterval(new Duration(10, TimeUnit.SECONDS))
                .setFailureRatioThreshold(0.5)
                .setEnabled(false);

        ConfigAssertions.assertFullMapping(properties, expected);
    }
}
