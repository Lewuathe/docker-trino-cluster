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
package io.prestosql.parquet.dictionary;

import org.apache.parquet.bytes.BytesUtils;
import org.apache.parquet.column.values.ValuesReader;
import org.apache.parquet.column.values.rle.RunLengthBitPackingHybridDecoder;
import org.apache.parquet.io.ParquetDecodingException;
import org.apache.parquet.io.api.Binary;

import java.io.ByteArrayInputStream;
import java.io.IOException;

import static com.google.common.base.Preconditions.checkArgument;

public class DictionaryReader
        extends ValuesReader
{
    private final Dictionary dictionary;
    private RunLengthBitPackingHybridDecoder decoder;

    public DictionaryReader(Dictionary dictionary)
    {
        this.dictionary = dictionary;
    }

    @Override
    public void initFromPage(int valueCount, byte[] page, int offset)
            throws IOException
    {
        checkArgument(page.length > offset, "Attempt to read offset not in the  page");
        ByteArrayInputStream in = new ByteArrayInputStream(page, offset, page.length - offset);
        int bitWidth = BytesUtils.readIntLittleEndianOnOneByte(in);
        decoder = new RunLengthBitPackingHybridDecoder(bitWidth, in);
    }

    @Override
    public int readValueDictionaryId()
    {
        return readInt();
    }

    @Override
    public Binary readBytes()
    {
        return dictionary.decodeToBinary(readInt());
    }

    @Override
    public float readFloat()
    {
        return dictionary.decodeToFloat(readInt());
    }

    @Override
    public double readDouble()
    {
        return dictionary.decodeToDouble(readInt());
    }

    @Override
    public int readInteger()
    {
        return dictionary.decodeToInt(readInt());
    }

    @Override
    public long readLong()
    {
        return dictionary.decodeToLong(readInt());
    }

    @Override
    public void skip()
    {
        readInt();
    }

    private int readInt()
    {
        try {
            return decoder.readInt();
        }
        catch (IOException e) {
            throw new ParquetDecodingException(e);
        }
    }
}
