// These unit tests stress undocumented Z80 opcodes
const undocumentedOpcodeTests = [
  "4c", "4e", "54", "5c", "63", "64", "6b", "6c", "6e",
  "70", "71", "74", "7c", // base opcodes

  "cb30", "cb31", "cb32", "cb33", "cb34", "cb35", "cb36", "cb37", // CB opcodes

  "dd24", "dd25", "dd26", "dd2c", "dd2d", "dd2e", "dd44", "dd45", "dd4c",
  "dd4d", "dd54", "dd55", "dd5c", "dd5d", "dd60", "dd61", "dd62", "dd63",
  "dd64", "dd65", "dd67", "dd68", "dd69", "dd6a", "dd6b", "dd6c", "dd6d",
  "dd6f", "dd7c", "dd7d", "dd84", "dd85", "dd8c", "dd8d", "dd94", "dd95",
  "dd9c", "dd9d", "dda4", "dda5", "ddac", "ddad", "ddb4", "ddb5", "ddbc",
  "ddbd", "ddcb36", "ddfd00", // DD opcodes

  "fd24", "fd25", "fd26", "fd2c", "fd2d", "fd2e", "fd44", "fd45", "fd4c",
  "fd4d", "fd54", "fd55", "fd5c", "fd5d", "fd60", "fd61", "fd62", "fd63",
  "fd64", "fd65", "fd67", "fd68", "fd69", "fd6a", "fd6b", "fd6c", "fd6d",
  "fd6f", "fd7c", "fd7d", "fd84", "fd85", "fd8c", "fd8d", "fd94", "fd95",
  "fd9c", "fd9d", "fda4", "fda5", "fdac", "fdad", "fdb4", "fdb5", "fdbc",
  "fdbd", "fdcb36", // FD opcodes
];
