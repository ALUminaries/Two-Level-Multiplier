/*
 * Author: Maxwell Phillips
 * Acknowledgement: Nathan Hagerdorn, for the original version of the component generator.
 * Copyright: Ohio Northern University, 2023.
 * License: GPL v3
 * Usage: Change the size parameters (n, m) below to the desired length of the multiplier and multiplicand respectively. Build and run the program.
 */ 

#include <cmath>
#include <fstream>
#include <iostream>
#include <string>
#include <bitset>
#include <vector>

#define FILE_ENDING "_ngen.vhd"

// Prototypes
void genEncoder();
void genBarrelShifter();
void genDecoder();
void genPartialDecoder(std::ofstream &output, std::string name, 
                       int max, int upper_range, int lower_range);
void genAlgorithm();
void printLibraries(std::ofstream &output);
std::string intToBinaryString(int i);
void printParametersToTerminal();
void printBitVectorToTerminal(std::vector<bool> bv);
void increment(std::vector<bool> &bv);
void decrement(std::vector<bool> &bv);
bool isEmpty(std::vector<bool> bv);


// Size Parameters

/* 
Multiplier Length n
Must be a power of 2
Input to Priority Encoder, XOR, NOR
*/
const int n = 256;

/*
Multiplicand Length m
Must be a power of 2
Input to Barrel Shifter
*/
// using square multipliers for now, but can change this to something else
const int m = n; 

/*
Base 2 Logarithm of input length n
Output of Priority Encoder
Input to Decoder, Barrel Shifter
*/
const int log2n = log2(n);

// q is the least power of 2 greater than sqrt(n)
const int q = pow(2, (ceil(log2(sqrt(n)))));
const int log2q = log2(q);

// k is n/q
const int k = n/q;
const int log2k = log2(k);

void printParametersToTerminal() {
  std::cout << "Parameters: \n" 
            << "n = ...... " << n << std::endl
            << "m = ...... " << m << std::endl
            << "log_2(n) = " << log2n << std::endl
            << "q = ...... " << q << std::endl
            << "log_2(q) = " << log2q << std::endl
            << "k = ...... " << k << std::endl
            << "log_2(k) = " << log2k << std::endl;
}

void printBitVectorToTerminal(std::vector<bool> bv) {
  std::cout << "[ ";
  for (int i = bv.size() - 1; i >= 0; i--) {
    std::cout << bv[i] << " ";
  }
  std::cout << "]\n";
}

// Print libraries common to all files
void printLibraries(std::ofstream &output) {
  output
  << "library IEEE;\n"
  << "use IEEE.std_logic_1164.all;\n"
  << "use IEEE.numeric_std.all;\n"
  << "use IEEE.std_logic_unsigned.all;\n\n";
}

int main(void) {
  printParametersToTerminal();
  genEncoder();
  genBarrelShifter();
  genDecoder();
  genAlgorithm();
  return 0;
}



void genEncoder() {
  std::ofstream output;
  std::string entityName = "priority_encoder_" + std::to_string(n);
	std::string filename = entityName + FILE_ENDING;
  std::cout << "Creating " << filename << std::endl;
	output.open(filename);

  printLibraries(output);

  //
  // Entity
  //

  // Begin Entity
  output << "entity " << entityName << " is" << std::endl;
  
  // Priority-Encoder-Specific Generics
  output
  << "generic(\n"
  << "  g_n:      integer := " << n << ";  -- Input (multiplier) length is n\n"
  << "  g_log2n:  integer := " << log2n << ";  -- Base 2 Logarithm of input length n; i.e., output length\n"
  << "  g_q:      integer := " << q << ";  -- q is the least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))\n"
  << "  g_log2q:  integer := " << log2q << ";  -- Base 2 Logarithm of q\n"
  << "  g_k:      integer := " << k << ";  -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q\n"
  << "  g_log2k:  integer := " << log2k << "  -- Base 2 Logarithm of k\n"
  << ");\n";

  // IO Ports
  output
  << "port(\n"
  << "  input: in std_logic_vector(g_n-1 downto 0);\n"
  << "  output: out std_logic_vector(g_log2n-1 downto 0)\n"
  << ");\n";

  // End Entity
  output << "end " << entityName << ";\n\n";

  //
  // Architecture
  //

  output << "architecture behavioral of " << entityName << " is\n\n";

  // Components
  // Import Coarse Encoder Component
  output
  << "component priority_encoder_" << k << "\n"
  << "port(\n"
    << "  input: in std_logic_vector(g_k - 1 downto 0);\n"
    << "  output: out std_logic_vector(g_log2k - 1 downto 0)\n"
  << ");\n" 
  << "end component;\n\n";

  // Import Fine Encoder Component
  // If we need another size of encoder, print it, otherwise don't
  if (q != k) {
    output
    << "component priority_encoder_" << q << "\n"
    << "port(\n"
    << "  input: in std_logic_vector(g_q - 1 downto 0);\n"
    << "  output: out std_logic_vector(g_log2q - 1 downto 0)\n"
    << ");\n"
    << "end component;\n\n";
  }

  // Signals
  output << "signal c_output: std_logic_vector(g_log2k - 1 downto 0); "
         << "-- coarse encoder output, select input signal for mux\n";
  output << "signal f_input: std_logic_vector(g_q - 1 downto 0); "
         << "-- fine encoder input\n";
  output << "signal slice_or: std_logic_vector(g_k - 1 downto 0); "
         << "-- there should be `k` or gates with q inputs each. last is effectively unused\n";
  // there should be `k` OR gates, each with `q` inputs.
  // the last OR gate is effectively unused, because 
  // it's an `else` case of the `when` when we select `f_input` later

  // Begin Component Logic
  output << std::endl << "begin\n";

  // Generate the actual OR Gates
  // See ~10 lines above for explanation
  std::string or_str = "";
  for (int i = k - 1; i > 0; i--) {
    or_str.append("slice_or(").append(std::to_string(i)).append(")");
    if (i < 10) or_str.append(" "); // ensure even padding
    or_str.append(" <= ");
    for (int j = 1; j <= q; j++) {
      or_str.append("input(");
      int pos = (q * (i + 1)) - j; // i must be +1 to reach n - 1 bits, otherwise it's q (or maybe k) off
      or_str.append(std::to_string(pos));

      if (j < q) {
        or_str.append(") or ");
      } else {
        or_str.append(");\n\n");
      }
      
      if (j % 8 == 0 && j < q) {
        or_str.append("\n");
        or_str.append("                "); // space properly
      }
    }
    output << or_str;
    or_str = "";
  }

  output << "slice_or(0) <= '1'; -- shouldn't matter if it's 0 or 1, it isn't looked at anyway\n\n";

  // Coarse Encoder
  output << "coarse_encoder: priority_encoder_" << k 
         << " port map(slice_or, c_output);\n\n";

  std::string sel_str = "";
  int upper, lower; // upper and lower bounds for each slice
  int dn, u, l, diff;
  for (int i = k; i > 0; i--) {
    upper = (q * i) - 1;
    lower = q * (i - 1);
    sel_str.append("  input(")
    .append(std::to_string(upper))
    .append(" downto ")
    .append(std::to_string(lower))
    .append(")");

    dn = floor(log10(n)) + 1; // # of digits in n
    u = floor(log10(upper)) + 1; // # of digits in upper limit
    l = floor(log10(lower)) + 1; // # of digits in lower limit
    diff = (2 * dn) - (u + l); // # of spaces to add
    // std::cout << "diff = " << diff << "\n";

    if (i > 1) {
      for (int j = 0; j < diff; j++) {
        sel_str.append(" ");
      }
      sel_str.append(" when c_output = \"");
      std::string bs = intToBinaryString(i - 1);
      
      sel_str.append(bs).append("\"");
      diff = floor(log2k) - bs.length();
      for (int j = 0; j < diff; j++) {
        sel_str.append(" ");
      }
      sel_str.append(" else\n");
    }
    else sel_str.append(";\n");

  }
  // Select Bit Slice based on c_output
  output << "f_input <= \n" << sel_str << std::endl;

  // Fine Encoder
  output << "fine_encoder: priority_encoder_" << q 
         << " port map(f_input, output(g_log2q - 1 downto 0));\n\n";

  output << "output(g_log2n - 1 downto g_log2q) <= c_output(g_log2k - 1 downto 0);\n";

  // End Component Logic
  output << "end;";
  output.close();
  std::cout << "Created " << filename << std::endl;
}

void genBarrelShifter() {
  std::ofstream output;
  std::string entityName = "barrel_shifter_" + std::to_string(n);
	std::string filename = entityName + FILE_ENDING;
  std::cout << "Creating " << filename << std::endl;
	output.open(filename);

  printLibraries(output);

  //
  // Entity
  //

  // Begin Entity
  output << "entity " << entityName << " is" << std::endl;

  // Generics
  output
  << "generic(\n"
  << "  g_n:      integer := " << n << ";  -- Input (multiplier) length is n\n"
  << "  g_log2n:  integer := " << log2n << ";  -- Base 2 Logarithm of input length n; i.e., output length\n"
  << "  g_m:      integer := " << m << ";  -- Input (multiplicand) length is m\n"
  << "  g_q:      integer := " << q << ";  -- q is the least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))\n"
  << "  g_log2q:  integer := " << log2q << ";  -- Base 2 Logarithm of q\n"
  << "  g_k:      integer := " << k << ";  -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q\n"
  << "  g_log2k:  integer := " << log2k << "  -- Base 2 Logarithm of k\n"
  << ");\n";

  output
  << "port(\n"
  << "  input: in std_logic_vector(g_m - 1 downto 0); -- input to shift, i.e., multiplicand Md\n"
  << "  shamt: in std_logic_vector(g_log2n - 1 downto 0); -- shift amount, i.e., floor(log_2(Mr))\n"
  << "  output: out std_logic_vector(g_m + g_n - 1 downto 0) -- shifted output\n"
  << ");\n";

  // End Entity
  output << "end " << entityName << ";\n\n";

  //
  // Architecture
  //

  output << "architecture behavioral of " << entityName << " is\n\n";

  // Signals
  output << "signal shamt_upper: std_logic_vector(g_log2k - 1 downto 0); "
         << "-- most significant log2(k) bits of shift amount\n";
  output << "signal shamt_lower: std_logic_vector(g_log2q - 1 downto 0); "
         << "-- least significant log2(q) bits of shift amount\n";
  output << "signal coarse_result: std_logic_vector(g_m + g_n - 2 downto 0); "
         << "-- result of coarse shifting\n";
  output << "signal fine_result: std_logic_vector(g_m + g_q - 2 downto 0); "
         << "-- result of fine shifting\n";
  output << "-- we do the fine shift first to reduce the hardware complexity of intermediate signals\n";
  
  // Constants
  output << "constant q_0s: std_logic_vector(g_q - 1 downto 0) := (others => '0'); "
         << "-- shorthand for q zeroes\n";

  // Begin Component Logic
  output << std::endl << "begin\n";

  output << "shamt_upper <= shamt(g_log2n - 1 downto g_log2q); -- log2(k) most significant bits\n";
  output << "shamt_lower <= shamt(g_log2q - 1 downto 0); -- log2(q) least significant bits\n\n";
  
  // Fine Shift
  output << "-- maximum fine shift: q - 1 bits\n";
  output << "fine_result <=\n";
  // generate cases for each fine shift amount from q - 1 down to 1
  for (int i = q - 1; i >= 1; i--) {
    output << "  "; // indent
    // generate the corresponding amount of zeroes before 'input'
    if ((q - 1) - i > 0) {
      output << "\"";
      for (int j = 0; j < ((q - 1) - i); j++) {
        output << "0";
      }
      output << "\" & ";
    } else output << "     ";
    output << "input & \"";
    // generate `i` zeroes
    for (int j = 0; j < i; j++) {
      output << "0";
    }
    // add padding to the output to align numbers and elses
    std::string padding = "";
    int digit_diff = (floor(log10(q - 1)) + 1) - (floor(log10(i)) + 1);
    if (digit_diff > 0) 
      for (int k = 0; k < digit_diff; k++)
        padding += " ";
    output << "\" when shamt_lower = " << i << padding << " else\n";
  }
  output << "  \"";
  // generate `q` zeroes
  for (int j = 0; j < q - 1; j++) {
    output << "0";
  }
  output << "\" & input;\n\n";

  // Coarse Shift
  output << "coarse_result <=\n";
  // generate cases for each coarse shift amount from k - 1 down to 1
  for (int i = k - 1; i >= 1; i--) {
    output << "  "; // indent
    // generate the corresponding amount of zeroes before 'input'
    if ((k - 1) - i > 0) {
      for (int j = 0; j < ((k - 1) - i); j++) {
        output << "q_0s & ";
      }
    }
    output << "fine_result ";
    // generate `i` sets of `q` zeroes
    for (int j = 0; j < i; j++) {
      output << "& q_0s ";
    }
    output << "when shamt_upper = " << i << " else\n";
  }
  output << "  "; // indent
  // generate `k` sets of `q` zeroes
  for (int j = 0; j < k - 1; j++) {
    output << "q_0s & ";
  }
  output << "fine_result;\n\n";

  // output final result
  output << "output <= '0' & coarse_result;\n";
  
  // End Component Logic
  output << "end;";
  output.close();
  std::cout << "Created " << filename << std::endl;
}

void genDecoder() {
  std::ofstream output;
  std::string entityName = "decoder_" + std::to_string(n);
	std::string filename = entityName + FILE_ENDING;
  std::cout << "Creating " << filename << std::endl;
	output.open(filename);

  printLibraries(output);

  //
  // Entity
  //

  // Begin Entity
  output << "entity " << entityName << " is" << std::endl;

  // Generics
  output
  << "generic(\n"
  << "  g_n:      integer := " << n << ";  -- Input (multiplier) length is n\n"
  << "  g_log2n:  integer := " << log2n << ";  -- Base 2 Logarithm of input length n; i.e., output length\n"
  << "  g_q:      integer := " << q << ";  -- q is the least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))\n"
  << "  g_log2q:  integer := " << log2q << ";  -- Base 2 Logarithm of q\n"
  << "  g_k:      integer := " << k << ";  -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q\n"
  << "  g_log2k:  integer := " << log2k << "  -- Base 2 Logarithm of k\n"
  << ");\n";

  output
  << "port(\n"
  << "  input: in std_logic_vector(g_log2n - 1 downto 0); -- value to decode, i.e., shift amount for multiplication)\n"
  << "  output: out std_logic_vector(g_n - 1 downto 0) -- decoded result (C_i)\n"
  << ");\n";

  // End Entity
  output << "end " << entityName << ";\n\n";

  //
  // Architecture
  //

  output << "architecture behavioral of " << entityName << " is\n\n";

  // Signals
  output 
    << "signal col: std_logic_vector(g_k - 1 downto 0);"
    << " -- column/coarse decoder, handles log2k most significant bits of input\n"
    << "signal row: std_logic_vector(g_q - 1 downto 0);"
    << " -- row/fine decoder, handles log2q least significant bits of input\n"
    << "signal result: std_logic_vector(g_n - 1 downto 0);"
    << " -- result of decoding, i.e., 2^{input}\n\n";

  output << "begin\n";
  output << "-- Decoding corresponds to binary representation of given portions of shift\n\n";


  genPartialDecoder(output, "col", k, log2n - 1, log2q);

  output << std::endl;

  genPartialDecoder(output, "row", q, log2q - 1, 0);

  output << "\n\n";

  output 
    << "-- generates each bit of the decoder result\n"
    << "-- see two-level decoder block diagram\n"
    << "coarse: for i in g_k - 1 downto 0 generate -- generate columns\n"
    << "  fine: for j in g_q - 1 downto 0 generate -- generate rows\n"
    << "    result((g_q * i) + j) <= col(i) and row(j);\n"
    << "  end generate fine;\n"
    << "end generate coarse;\n\n";

  output << "output <= result;\n";

  // End Component Logic
  output << "end;";
  output.close();
  std::cout << "Created " << filename << std::endl;
}

/// @brief Generates a small single level decoder
/// @param name the name of the signal vector to be assigned
/// @param max the output width of the decoder
/// @param upper_range the upper limit of 'input' to take
/// @param lower_range the lower limit of 'input' to take
void genPartialDecoder(std::ofstream &output, std::string name, 
                       int max, int upper_range, int lower_range) {
  
  // create full bit vector which can hold max - 1
  std::vector<bool> bv(log2(max), 1); 
  
  // generate max:log2(max) decoder
  for (int i = max - 1; i >= 0; i--) {
    // add padding if necessary
    std::string padding = "";
    int digit_diff = (floor(log10(max - 1)) + 1) - (floor(log10(i)) + 1);
    if (digit_diff > 0) 
      for (int k = 0; k < digit_diff; k++)
        padding += " ";
    if (i == 0) padding += " ";

    output << name << "(" << i << ")" << padding << " <= ";
    // convert binary representation of 'i' to decoder row
    for (int j = upper_range; j >= lower_range; j--) {
      if (bv[j - lower_range] == 0) output << "not ";
      output << "input(" << j << ")";
      if (j > lower_range) output << " and ";
      else output << ";\n";
    }
    decrement(bv);
    // printBitVectorToTerminal(bv);
  }
}

void genAlgorithm() {
  std::ofstream output;
  std::string entityName = "multiplier_" + std::to_string(n);
	std::string filename = entityName + FILE_ENDING;
  std::cout << "Creating " << filename << std::endl;
	output.open(filename);

  output << "library IEEE;\n"
  << "use IEEE.std_logic_1164.all;\n"
  << "use IEEE.numeric_std.all;\n"
  << "use IEEE.std_logic_unsigned.all;\n"
  << "use IEEE.std_logic_misc.all;\n\n";

  //
  // Entity
  //

  // Begin Entity
  output << "entity " << entityName << " is" << std::endl;

  // Generics
  output
  << "generic(\n"
  << "  g_n:      integer := " << n << ";  -- Input (multiplier) length is n\n"
  << "  g_log2n:  integer := " << log2n << ";  -- Base 2 Logarithm of input length n; i.e., output length\n"
  << "  g_m:      integer := " << m << ";  -- Input (multiplicand) length is m\n"
  << "  g_q:      integer := " << q << ";  -- q is the least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))\n"
  << "  g_log2q:  integer := " << log2q << ";  -- Base 2 Logarithm of q\n"
  << "  g_k:      integer := " << k << ";  -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q\n"
  << "  g_log2k:  integer := " << log2k << "  -- Base 2 Logarithm of k\n"
  << ");\n";

  output
  << "port(\n"
  << "  clk: in std_logic;\n"
  << "  start: in std_logic;\n"
  << "  reset: in std_logic;\n"
  << "  mr: in std_logic_vector(g_n - 1 downto 0);\n"
  << "  s_mr: in std_logic;\n"
  << "  md: in std_logic_vector(g_m - 1 downto 0);\n"
  << "  s_md: in std_logic;\n"
  << "  prod: out std_logic_vector(g_n + g_m - 1 downto 0);\n"
  << "  s_prod: out std_logic;\n"
  << "  done: out std_logic\n"
  << ");\n";

  // End Entity
  output << "end " << entityName << ";\n\n";

  //
  // Architecture
  //

  output << "architecture structural of " << entityName << " is\n\n";

  // Components
  // Import Priority Encoder
  output
  << "  component priority_encoder_" << n << "\n"
  << "  port(\n"
  << "    input: in std_logic_vector(g_n-1 downto 0);\n"
  << "    output: out std_logic_vector(g_log2n-1 downto 0)\n"
  << "  );\n"
  << "  end component;\n\n";

  // Import Barrel Shifter
  output
  << "  component barrel_shifter_" << n << "\n"
  << "  port(\n"
  << "    input: in std_logic_vector(g_m - 1 downto 0); -- input to shift, i.e., multiplicand Md\n"
  << "    shamt: in std_logic_vector(g_log2n - 1 downto 0); -- shift amount, i.e., floor(log_2(Mr))\n"
  << "    output: out std_logic_vector(g_m + g_n - 1 downto 0) -- shifted output\n"
  << "  );\n"
  << "  end component;\n\n";

  // Import Decoder
  output
  << "  component decoder_" << n << "\n"
  << "  port(\n"
  << "    input: in std_logic_vector(g_log2n - 1 downto 0); -- value to decode, i.e., shift amount for multiplication)\n"
  << "    output: out std_logic_vector(g_n - 1 downto 0) -- decoded result (C_i)\n"
  << "  );\n"
  << "  end component;\n\n";

  // Import CLA
  output
  << "  component CLA" << n + m << "\n"
  << "  port(\n"
  << "    A, B: in std_logic_vector(g_n + g_m - 1 downto 0);\n"
  << "    Ci: in std_logic;\n"
  << "    S: out std_logic_vector(g_n + g_m - 1 downto 0);\n"
  << "    Co, PG, GG: out std_logic\n"
  << "  );\n"
  << "  end component;\n\n";

  // Registers
  output
  << "  -- Registers\n"
  << "  signal mr_reg: std_logic_vector(g_n - 1 downto 0) := (others => '1');\n"
  << "  signal prod_reg: std_logic_vector(g_n + g_m - 1 downto 0);\n\n";

  // Intermediate Signals
  output
  << "  -- Intermediate Signals\n"
  << "  signal encoder_output: std_logic_vector(g_log2n - 1 downto 0);\n"
  << "  signal decoder_output: std_logic_vector(g_n - 1 downto 0);\n"
  << "  signal shifter_output: std_logic_vector(g_n + g_m - 1 downto 0);\n"
  << "  signal xor_output: std_logic_vector(g_n - 1 downto 0);\n"
  << "  signal adder_output: std_logic_vector(g_n + g_m - 1 downto 0);\n"
  << "  signal adder_cout: std_logic;\n"
  << "  signal hw_done: std_logic := '0';\n"
  << "  signal active: std_logic := '0';\n"
  << "  attribute dont_touch: string;\n"
  << "  attribute dont_touch of shifter_output: signal is \"true\";\n"
  << "  attribute dont_touch of active: signal is \"true\";\n\n";


  // Begin
  output << "begin\n";
  
  // Instantiate Components
  int claSize = std::max(n, m) * 2; // least required is n + m, but cla is best in powers of 4, or doable in powers of 2.
  output
  << "  -- Instantiate Components\n"
  << "  encoder: priority_encoder_" << n << " port map(mr_reg, encoder_output);\n"
  << "  decoder: decoder_" << n << " port map(encoder_output, decoder_output);\n" // Nathan's code had a zero flag input as 'done', maybe consider this
  << "  shifter: barrel_shifter_" << n << " port map(md, encoder_output, shifter_output);\n"
  << "  adder: CLA" << claSize << " port map(\n"
  << "    A => prod_reg,\n"
  << "    B => shifter_output,\n"
  << "    Ci => '0',\n"
  << "    S => adder_output,\n"
  << "    Co => adder_cout,\n"
  << "    PG => open,\n"
  << "    GG => open\n"
  << "  );\n\n"; 

  // Assigning Signals
  output 
  << "  xor_output <= mr_reg xor decoder_output;\n"
  << "  prod <= prod_reg;\n"
  << "  s_prod <= s_mr xor s_md;\n"
  << "  hw_done <= not or_reduce(mr_reg);\n\n";

  // Clock Sensitive Logic
  output
  << "  process (clk, reset) begin\n"
  << "    if (reset = '1') then\n"
  << "      mr_reg <= (others => '1'); -- set all 1s initially to avoid premature done\n"
  << "      prod_reg <= (others => '0');\n"
  << "      done <= '0';\n"
  << "    elsif (clk'event and clk = '1') then\n"
  << "      done <= hw_done;\n"
  << "      if (start = '1' and active = '0') then\n"
  << "        mr_reg <= mr; -- take initial value of multiplier\n"
  << "        prod_reg <= (others => '0'); -- reset product register\n"
  << "        active <= '1';\n"
  << "      elsif (active = '1' and hw_done = '0') then\n"
  << "        mr_reg <= xor_output;\n"
  << "        prod_reg <= adder_output;\n"
  << "      end if;\n"
  << "    end if;\n"
  << "  end process;\n";

  // End Component Logic
  output << "end;";
  output.close();
  std::cout << "Created " << filename << std::endl;
}

bool isEmpty(std::vector<bool> bv) {
  for (int i = 0; i < bv.size(); i++) {
    if (bv[i] == 1) return false;
  }
  return true;
}

void increment(std::vector<bool> &bv) {
    // add 1 to each value, and if it was 1 already, carry the 1 to the next.
  for (int i = 0; i < bv.size(); i++) {
    if (bv[i] == 0) { // there will be no carry
      bv[i] = 1;
      break;
    }
    bv[i] = 0; // this entry was 1; set to zero and carry the 1
  }
}

void decrement(std::vector<bool> &bv) {
  if (isEmpty(bv)) { // if empty, bv value == 0, so don't decrement
    return;
  } else if (bv[0] == 1) { // subtract 1 if possible...
    bv[0] = 0;
  } else { // otherwise borrow
    for (int i = 1; i < bv.size(); i++) {
      if (bv[i] == 1) {
        bv[i] = 0;
        while (i > 0) {
          i--;
          bv[i] = 1;
        }
        break;
      }
    }
  }
}

std::string intToBinaryString(int i) {
  int size = floor(log2(i)) + 1;
  // std::cout << "size = " << size << std::endl;
  char str[size + 1];
  for (int j = 0; j < size; j++) {
    str[j] = '0';
  }
  int j; // value to subtract from i
  while (i > 0) {
    j = floor(log2(i));
    // std::cout << "j is " << j << ", i is " << i << std::endl;
    i -= pow(2, j);
    // std::cout << "i is now " << i << std::endl;
    str[size - j - 1] = '1';
    // std::cout << "str = ";
    // for (int k = 0; k < size; k++) {
      // std::cout << str[k];
    // }
    // std::cout << std::endl;
  }
  str[size] = '\0';
  std::string s(str);
  // std::cout << "Final Result: " << s << std::endl;
  return s;
}