// ignore_for_file: non_constant_identifier_names

class FuseTest {
  final String testName;
  final FuseTestInput input;
  final FuseTestResult results;
  final bool isUndocumented;

  const FuseTest(this.testName, this.input, this.results,
      {this.isUndocumented = false});
}

class FuseTestInput {
  final Registers reg;
  final SpecialRegisters spec;
  final Map<int, List<int>> initialMemorySetup;

  const FuseTestInput(this.reg, this.spec, this.initialMemorySetup);
}

class FuseTestResult {
  final Registers reg;
  final SpecialRegisters spec;
  final Map<int, String> expectedMemory;

  const FuseTestResult(this.reg, this.spec, this.expectedMemory);
}

class Registers {
  final int af;
  final int bc;
  final int de;
  final int hl;
  final int af_;
  final int bc_;
  final int de_;
  final int hl_;
  final int ix;
  final int iy;
  final int sp;
  final int pc;

  Registers(
      {this.af = 0,
      this.bc = 0,
      this.de = 0,
      this.hl = 0,
      this.af_ = 0,
      this.bc_ = 0,
      this.de_ = 0,
      this.hl_ = 0,
      this.ix = 0,
      this.iy = 0,
      this.sp = 0,
      this.pc = 0});
}

class SpecialRegisters {
  final int i;
  final int r;
  final int iff1;
  final int iff2;
  final int im;
  final bool halted;
  final int tStates;

  SpecialRegisters(
      {this.i = 0,
      this.r = 0,
      this.iff1 = 0,
      this.iff2 = 0,
      this.im = 0,
      this.halted = false,
      this.tStates = 0});
}
