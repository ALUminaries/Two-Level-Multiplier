/*
 * Title: High-Level Example of Two-Level Multiplication Algorithm
 * Description:
 *   This program emulates the functionality of the hardware implementation
 *   of the two-level multiplication algorithm proposed in our paper.
 *   It uses a ripple-carry adder instead of a carry-look-ahead adder for simplicity.
 *
 * Author: Maxwell Phillips
 * Copyright: Ohio Northern University, 2023.
 * License: GPL v3
 * Usage: Pass two arguments as bit strings to multiply.
 */

import kotlin.math.max
import kotlin.math.pow

open class BitVector(var content: String = "", length: Int = content.length) {
    var length: Int = length
        protected set(newLength) {
            if (newLength >= 0) {
                field = newLength
            }
        }

    override fun toString(): String {
        return content
    }

    fun truncate(newLength: Int) {
        if (newLength in 0 until length) {
            // truncate content to (newLength) least significant bits
            content = content.takeLast(newLength)
            length = newLength
        }
    }

    fun padTo(newLength: Int): BitVector {
        if (newLength > length) {
            // pad content with zeroes
            var newContent = ""
            for (i in 0 until newLength - length)
                newContent += '0'
            newContent += content
            content = newContent
            length = newLength
            return BitVector(newContent, newLength)
        }
        return this
    }

    fun padWith(bits: Int): BitVector {
        return padTo(length + bits)
    }

    companion object {
        fun zeroes(bits: Int): BitVector {
            return BitVector(CharArray(bits) { '0' }.joinToString(""))
        }
    }

    fun clear() { truncate(0) }

    operator fun get(index: Int): Char {
        return content[index]
    }

    operator fun set(index: Int, value: Char) {
        val arr = content.toCharArray()
        arr[index] = value;
        content = arr.joinToString("")
    }

    inner class BoolBitVector(var boolArr: BooleanArray = this.toBoolArray()) {
        override fun toString(): String {
            var str = "[ "
            for (b in boolArr) str += "$b "
            str += "]"
            return str
        }
        fun reversed(): BoolBitVector {
            return BoolBitVector(boolArr.reversed().toBooleanArray())
        }
        fun toBitVector(): BitVector {
            var result = ""
            for (element in boolArr) {
                result += if (element) '1' else '0'
            }
            return BitVector(result)
        }
        operator fun get(index: Int): Boolean {
            return boolArr[index]
        }
        operator fun set(index: Int, value: Boolean) {
            boolArr[index] = value;
        }
        val length: Int
            get() { return boolArr.size }

        fun bitwiseNOR(): Boolean {
            for (ch in boolArr) {
                if (ch) return false
            }
            return true
        }

        fun bitwiseXOR(other: BoolBitVector): BoolBitVector {
            val paddedThis = this.toBitVector().padTo(other.length).toBoolBitVector()
            val paddedOther = other.toBitVector().padTo(this.length).toBoolBitVector()
            val result = paddedThis
            for (bit in result.boolArr.indices) {
                result.boolArr[bit] = paddedThis.boolArr[bit] xor paddedOther.boolArr[bit]
            }
            return result
        }
    }

    private fun toBoolArray(): BooleanArray {
        val result = BooleanArray(length)
        for (i in 0 until length) {
            if (content[i] == '1') result[i] = true
        }
        return result
    }

    fun toBoolBitVector(): BoolBitVector {
        return BoolBitVector()
    }

    open fun toDecimal(): Int {
        var sum: Int = 0
        for (i in 0 until length) {
            if (content.reversed()[i] == '1') {
                sum += (2.0).pow(i.toDouble()).toInt()
            }
        }
        return sum
    }

    fun concatenate(other: BitVector): BitVector {
        val sb = StringBuilder()
        sb.append(this.content)
        sb.append(other.content)
        return BitVector(sb.toString())
    }

    fun prepend(prefix: BitVector) = prefix.concatenate(this)

    fun sumHighBits(): Int {
        var h = 0
        for (c in content) {
            if (c == '1') h++
        }
        return h
    }
}

class RippleCarryAdder(var augend: BitVector = BitVector("0"),
                       var addend: BitVector = BitVector("0"),
                       carryIn: Boolean = false) {

    private var length = max(augend.length, addend.length)
    private var carry = carryIn
    private var sum = BitVector.zeroes(length).toBoolBitVector()
    private var a = false
    private var b = false

    fun add(): BitVector {
        val augend2 = augend.toBoolBitVector().reversed()
        val addend2 = addend.toBoolBitVector().reversed()
        for (i in 0 until length) {
            a = augend2[i]
            b = addend2[i]
            sum[i] = ( a.xor(b) ).xor(carry)
            carry = (a && b) || (a.xor(b) && carry)
        }
        return sum.reversed().toBitVector()
    }
    val carryOut: Boolean
        get() { return carry }
    fun getSum(): BitVector {
        return sum.toBitVector()
    }
    fun getExtendedSum(): BitVector {
        val result = getSum().padWith(1)
        if (carryOut) result[0] = '1'
        return result
    }
}

class TwoLevelMultiplier(
    var multiplierSign: BitVector = BitVector("0"),
    var multiplier: BitVector = BitVector("0"),
    var multiplicandSign: BitVector = BitVector("0"),
    var multiplicand: BitVector = BitVector("0")
) {
    private var mr = multiplier.toBoolBitVector()
    private var md = multiplicand.toBoolBitVector()
    private var product = BitVector.zeroes(multiplier.length + multiplicand.length)

    // Performs the multiplication operation and returns the product.
    fun multiply(): BitVector {
        var done = false
        var shamt: Int
        var iterations = 1
        val header = "${multiplierSign}_$multiplier * ${multiplicandSign}_$multiplicand"
        println(header)
        for (i in 1..header.length) print("-")
        println()
        do {
            println("Iteration $iterations:")
            println("Mr_i:   ${mr.toBitVector()}")
            shamt = encode(mr)
            println("Sh_i:   $shamt bits")
            val partialProduct = shift(multiplicand, shamt).padTo(product.length)
            println("Pp_i:   $partialProduct")
            product = RippleCarryAdder(product, partialProduct).add()
            println("Prod_i: $product")
            val decodedValue = decode(shamt).toBoolBitVector()
            println("C_i:    ${decodedValue.toBitVector()}")
            mr = mr.bitwiseXOR(decodedValue)
            //mr[shamt] = false // this would also function identically to decoding
            done = mr.bitwiseNOR()
            println("Done:   $done")
            iterations++
            println()
        } while (!done)
        println("Total Iterations: ${iterations - 1}") // subtract 1 because iterations starts at 1
        println("Number of high bits in multiplier (h): ${multiplier.sumHighBits()}")
        println()

        return product
    }

    // Returns the sign of the product.
    fun getSign(): BitVector {
        val sMr = multiplierSign.toBoolBitVector()
        val sMd = multiplicandSign.toBoolBitVector()
        val sProd = sMr[0] xor sMd[0]
        val sProdChar = if (sProd) "1" else "0"
        return BitVector(sProdChar)
    }

    // Software emulation of a priority encoder.
    // Returns the position of the most significant high bit, or -1 if all zeroes.
    fun encode(bv: BitVector.BoolBitVector): Int {
        for (i in bv.boolArr.indices) {
            if (bv.boolArr[i]) return (bv.length - i - 1)
        }
        return -1
    }

    fun decode(shamt: Int): BitVector {
        val sb = StringBuilder().append("1")
        for (i in 0 until shamt) {
            sb.append("0")
        }
//        println(sb.toString())
        return BitVector(sb.toString())
    }

    // Shifts the specified bit vector left by `shamt` bits
    fun shift(bv: BitVector, shamt: Int): BitVector {
        var newContent = bv.content
        for (i in 0 until shamt)
            newContent += "0"
        return BitVector(newContent)
    }
}

fun main(args: Array<String>) {
    val multiplier = try {
        if (args[0].isNotEmpty()) BitVector(args[0])
        else throw IndexOutOfBoundsException()
    } catch(e: IndexOutOfBoundsException) { BitVector("10001011") }

    val multiplicand = try { BitVector(args[1]) }
        catch(e: IndexOutOfBoundsException) { BitVector("01011011") }

    println("Multiplying as Unsigned Integers:")
    val twoLevelMultiplier = TwoLevelMultiplier(multiplier = multiplier, multiplicand = multiplicand)
    val product = twoLevelMultiplier.multiply()
    println("Base 10: ${multiplier.toDecimal()} * ${multiplicand.toDecimal()} = ${product.toDecimal()}")
    println("Base 2: ${multiplier.content} * ${multiplicand.content} = ${product.content}")

    println()
    println("=====================================================")
    println()
    println("Multiplying as Signed Integers")
    val sMr = BitVector(multiplier.content[0].toString())
    val mr = BitVector(multiplier.content.drop(1))
    val sMd = BitVector(multiplicand.content[0].toString())
    val md = BitVector(multiplicand.content.drop(1))
    val signedTwoLevelMultiplier = TwoLevelMultiplier(multiplierSign = sMr, multiplier = mr, multiplicandSign = sMd, multiplicand = md)
    val product2 = signedTwoLevelMultiplier.multiply()
    val sProd2 = signedTwoLevelMultiplier.getSign()
    val neg = { c: Char -> when (c) {'1' -> "-"; else -> "+"}}

    println("Base 10: ${neg(sMr[0])}${mr.toDecimal()} * ${neg(sMd[0])}${md.toDecimal()} = ${neg(sProd2[0])}${product2.toDecimal()}")
    println("Base 2: ${sMr}_${mr.content} * ${sMd}_${md.content} = ${sProd2}_${product2.content}")
}

