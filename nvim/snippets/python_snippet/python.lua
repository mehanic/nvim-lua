local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  -- 🔹 if statement
  s({ trig = "if", dscr = "if condition: statement" }, {
    t("if "),
    i(1, "condition"),
    t(":"),
    t({ "", "\t" }),
    i(2, "pass"),
    i(0),
  }),

  -- 🔹 if/else statement
  s({ trig = "if-else", dscr = "if/else conditional block" }, {
    t("if "),
    i(1, "condition"),
    t(":"),
    t({ "", "\t" }),
    i(2, "pass"),
    t({ "", "else:" }),
    t({ "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 elif statement
  s({ trig = "elif", dscr = "elif condition: statement" }, {
    t("elif "),
    i(1, "condition"),
    t(":"),
    t({ "", "\t" }),
    i(2, "pass"),
    i(0),
  }),

  -- 🔹 else block
  s({ trig = "else", dscr = "else: block" }, {
    t("else:"),
    t({ "", "\t" }),
    i(1, "pass"),
    i(0),
  }),

  -- 🔹 while loop
  s({ trig = "while", dscr = "while loop" }, {
    t("while "),
    i(1, "condition"),
    t(":"),
    t({ "", "\t" }),
    i(2, "pass"),
    i(0),
  }),

  -- 🔹 while/else loop
  s({ trig = "while-else", dscr = "while loop with else clause" }, {
    t("while "),
    i(1, "condition"),
    t(":"),
    t({ "", "\t" }),
    i(2, "pass"),
    t({ "", "else:" }),
    t({ "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 if statement
  s({ trig = "if", dscr = "if condition: statement" }, {
    t("if "),
    i(1, "condition"),
    t(":"),
    t({ "", "\t" }),
    i(2, "pass"),
    i(0),
  }),

  -- 🔹 if/else statement
  s({ trig = "if-else", dscr = "if/else conditional block" }, {
    t("if "),
    i(1, "condition"),
    t(":"),
    t({ "", "\t" }),
    i(2, "pass"),
    t({ "", "else:" }),
    t({ "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 elif statement
  s({ trig = "elif", dscr = "elif condition: statement" }, {
    t("elif "),
    i(1, "condition"),
    t(":"),
    t({ "", "\t" }),
    i(2, "pass"),
    i(0),
  }),

  -- 🔹 else block
  s({ trig = "else", dscr = "else: block" }, {
    t("else:"),
    t({ "", "\t" }),
    i(1, "pass"),
    i(0),
  }),

  -- 🔹 while loop
  s({ trig = "while", dscr = "while loop" }, {
    t("while "),
    i(1, "condition"),
    t(":"),
    t({ "", "\t" }),
    i(2, "pass"),
    i(0),
  }),

  -- 🔹 while/else loop
  s({ trig = "while-else", dscr = "while loop with else clause" }, {
    t("while "),
    i(1, "condition"),
    t(":"),
    t({ "", "\t" }),
    i(2, "pass"),
    t({ "", "else:" }),
    t({ "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 Встав цей блок у ~/.config/nvim/snippets/python.lua всередину return { ... }

  -- 🔹 try/except/else
  s({ trig = "try-except_else", dscr = "try/except/else exception handling" }, {
    t({ "try:", "\t" }),
    i(1, "pass"),
    t({ "", "except " }),
    i(2, "Exception"),
    t(" as "),
    i(3, "e"),
    t(":"),
    t({ "", "\t" }),
    i(4, "pass"),
    t({ "", "else:" }),
    t({ "", "\t" }),
    i(5, "pass"),
    i(0),
  }),

  -- 🔹 try/except/finally
  s({ trig = "try-except-finally", dscr = "try/except/finally with cleanup" }, {
    t({ "try:", "\t" }),
    i(1, "pass"),
    t({ "", "except " }),
    i(2, "Exception"),
    t(" as "),
    i(3, "e"),
    t(":"),
    t({ "", "\t" }),
    i(4, "pass"),
    t({ "", "finally:" }),
    t({ "", "\t" }),
    i(5, "pass"),
    i(0),
  }),

  -- 🔹 try/except/else/finally
  s({ trig = "try-except-else-finally", dscr = "try/except/else/finally full pattern" }, {
    t({ "try:", "\t" }),
    i(1, "pass"),
    t({ "", "except " }),
    i(2, "Exception"),
    t(" as "),
    i(3, "e"),
    t(":"),
    t({ "", "\t" }),
    i(4, "pass"),
    t({ "", "else:" }),
    t({ "", "\t" }),
    i(5, "pass"),
    t({ "", "finally:" }),
    t({ "", "\t" }),
    i(6, "pass"),
    i(0),
  }),

  -- 🔹 with statement (context manager)
  s({ trig = "with", dscr = "with statement (context manager)" }, {
    t("with "),
    i(1, "open('file.txt')"),
    t(" as "),
    i(2, "f"),
    t(":"),
    t({ "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 def function
  s({ trig = "def", dscr = "def function definition" }, {
    t("def "),
    i(1, "func_name"),
    t("("),
    i(2, "args"),
    t("):"),
    t({ "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 def class method
  s({ trig = "method", dscr = "def class method with self" }, {
    t("def "),
    i(1, "method_name"),
    t("(self, "),
    i(2, "args"),
    t("):"),
    t({ "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 try/except/else
  s({ trig = "try-except-else", dscr = "try/except/else exception handling" }, {
    t({ "try:", "\t" }),
    i(1, "pass"),
    t({ "", "except " }),
    i(2, "Exception"),
    t(" as "),
    i(3, "e"),
    t(":"),
    t({ "", "\t" }),
    i(4, "pass"),
    t({ "", "else:" }),
    t({ "", "\t" }),
    i(5, "pass"),
    i(0),
  }),

  -- 🔹 try/except/finally
  s({ trig = "try-except-finally", dscr = "try/except/finally with cleanup" }, {
    t({ "try:", "\t" }),
    i(1, "pass"),
    t({ "", "except " }),
    i(2, "Exception"),
    t(" as "),
    i(3, "e"),
    t(":"),
    t({ "", "\t" }),
    i(4, "pass"),
    t({ "", "finally:" }),
    t({ "", "\t" }),
    i(5, "pass"),
    i(0),
  }),

  -- 🔹 try/except/else/finally
  s({ trig = "try-except-else-finally", dscr = "try/except/else/finally full pattern" }, {
    t({ "try:", "\t" }),
    i(1, "pass"),
    t({ "", "except " }),
    i(2, "Exception"),
    t(" as "),
    i(3, "e"),
    t(":"),
    t({ "", "\t" }),
    i(4, "pass"),
    t({ "", "else:" }),
    t({ "", "\t" }),
    i(5, "pass"),
    t({ "", "finally:" }),
    t({ "", "\t" }),
    i(6, "pass"),
    i(0),
  }),

  -- 🔹 with statement (context manager)
  s({ trig = "with", dscr = "with statement (context manager)" }, {
    t("with "),
    i(1, "open('file.txt')"),
    t(" as "),
    i(2, "f"),
    t(":"),
    t({ "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 def function
  s({ trig = "def", dscr = "def function definition" }, {
    t("def "),
    i(1, "func_name"),
    t("("),
    i(2, "args"),
    t("):"),
    t({ "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 def class method
  s({ trig = "method", dscr = "def class method with self" }, {
    t("def "),
    i(1, "method_name"),
    t("(self, "),
    i(2, "args"),
    t("):"),
    t({ "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 Встав цей блок у ~/.config/nvim/snippets/python.lua всередину return { ... }

  -- 🔹 @staticmethod class method
  s({ trig = "staticmethod", dscr = "@staticmethod class method" }, {
    t("@staticmethod"),
    t({ "", "def " }),
    i(1, "func_name"),
    t("("),
    i(2, "args"),
    t("):"),
    t({ "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 Abstract method (raises NotImplementedError)
  s({ trig = "abstractmethod", dscr = "Abstract method raising NotImplementedError" }, {
    t("def "),
    i(1, "func_name"),
    t("(self, "),
    i(2, "args"),
    t("):"),
    t({ "", "\t" }),
    t("raise NotImplementedError"),
    i(0),
  }),

  -- 🔹 Class definition
  s({ trig = "class", dscr = "Class definition" }, {
    t("class "),
    i(1, "ClassName"),
    t("("),
    i(2, "object"),
    t("):"),
    t({ "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 Lambda anonymous function
  s({ trig = "lambda", dscr = "Lambda anonymous function" }, {
    t("lambda "),
    i(1, "args"),
    t(": "),
    i(2, "expression"),
    i(0),
  }),

  -- 🔹 if __name__ == "__main__" block
  s({ trig = "main", dscr = "if __name__ == '__main__' block" }, {
    t({ 'if __name__ == "__main__":', "    " }),
    i(1, "pass"),
    i(0),
  }),

  -- 🔹 Async function definition
  s({ trig = "async-def", dscr = "Async function definition" }, {
    t("async def "),
    i(1, "func_name"),
    t("("),
    i(2, "args"),
    t("):"),
    t({ "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 Встав цей блок у ~/.config/nvim/snippets/python.lua всередину return { ... }
  -- ⚠️ Для pvar: local rep = require("luasnip.extras").rep

  -- 🔹 Read file with 'with open()'
  s({ trig = "readfile", dscr = "Open file for reading: with open() as f" }, {
    t("with open("),
    i(1, "'file.txt'"),
    t(") as f:"),
    t({ "", "\t" }),
    t("text = f.read()"),
    i(0),
  }),

  -- 🔹 Write file with 'with open()'
  s({ trig = "writefile", dscr = "Open file for writing: with open(..., 'w')" }, {
    t("with open("),
    i(1, "'file.txt'"),
    t(", 'w') as f:"),
    t({ "", "\t" }),
    t("f.write("),
    i(2, "text"),
    t(")"),
    i(0),
  }),

  -- 🔹 File encoding declaration
  s({ trig = "cod", dscr = "# -*- coding: utf-8 -*-" }, {
    t("# -*- coding: utf-8 -*-"),
    i(0),
  }),

  -- 🔹 File header comment (VSCode variables replaced with placeholders)
  s({ trig = "fileheader", dscr = "File header with metadata placeholders" }, {
    t({
      "# -*- coding: utf-8 -*-",
      "#",
      "#  ",
    }),
    i(1, "filename.py"),
    t({
      "",
      "#  ",
    }),
    i(2, "project_name"),
    t({
      "",
      "#",
      "#  Created by ",
    }),
    i(3, "Your Name"),
    t(" on "),
    i(4, "YYYY-MM-DD"),
    t({
      ".",
      "#  Copyright ",
    }),
    i(5, "YEAR"),
    t(" "),
    i(6, "Organization"),
    t(". All rights reserved."),
    t({
      "#",
      "#  ",
    }),
    i(7, "email"),
    t("@example.com", {
      "#",
      "# pylint: disable-msg=F0401",
    }),
    i(0),
  }),

  -- 🔹 Abstract method with NotImplementedError
  s({ trig = "abstractmethod", dscr = "Abstract method raising NotImplementedError" }, {
    t("def "),
    i(1, "name"),
    t("(self):"),
    t({ "", "\t" }),
    t(
      'raise NotImplementedError("This method is abstract. To provide a concrete implementation override this method in a subclass.")'
    ),
    i(0),
  }),

  -- 🔹 Print variable debugging helper
  s({ trig = "pvar", dscr = "Print debug: 'func: var = value'" }, {
    t("print('"),
    i(1, "func"),
    t(": "),
    i(2, "var"),
    t(" = {}'.format("),
    rep(2),
    t("))"),
    i(0),
  }),

  -- 🔹 Встав цей блок у ~/.config/nvim/snippets/python.lua всередину return { ... }
  -- ⚠️ Для rep(): local rep = require("luasnip.extras").rep

  -- 🔹 Entry point: main() + if __name__ == '__main__'
  s({ trig = "main", dscr = "Entry point: def main() + if __name__ block" }, {
    t("def "),
    i(1, "main"),
    t("():", {
      "",
      "\t",
    }),
    i(2, "# code here"),
    t({
      "",
      "",
      "",
      "if __name__ == '__main__':",
      "\t",
    }),
    rep(1),
    t("()"),
    i(0),
  }),

  -- 🔹 Simple class with __init__ and __str__
  s({ trig = "class1", dscr = "Simple class with __init__ and __str__" }, {
    t("class "),
    i(1, "Name"),
    i(2, "(object)"),
    t(":", {
      "",
      "\tdef __init__(self, ",
    }),
    i(3, "var"),
    t("):", {
      "",
      "\t\tself.",
    }),
    rep(3),
    t(" = "),
    rep(3),
    t({
      "",
      "\tdef __str__(self):",
      "",
      "\t\treturn '",
    }),
    rep(1),
    t("@{:#x}: {}'.format(id(self), self."),
    rep(3),
    t(")"),
    i(0),
  }),

  -- 🔹 Class with docstring + __init__ + __str__
  s({ trig = "class2", dscr = "Class with docstring, __init__, __str__" }, {
    t("class "),
    i(1, "Name"),
    i(2, "(object)"),
    t(":", {
      "",
      '\t""" ',
    }),
    i(3, "docstring"),
    t({
      "",
      '\t"""',
      "\tdef __init__(self, ",
    }),
    i(4, "var"),
    t("):", {
      "",
      "\t\tself.",
    }),
    rep(4),
    t(" = "),
    rep(4),
    t({
      "",
      "\tdef __str__(self):",
      "",
      "\t\treturn '",
    }),
    rep(1),
    t("@{:#x}: {}'.format(id(self), self."),
    rep(4),
    t(")"),
    i(0),
  }),

  -- 🔹 Function decorator template
  s({ trig = "decor", dscr = "Function decorator with logging wrapper" }, {
    t("def "),
    i(1, "name"),
    t("(fn):", {
      "",
      "\tdef ",
    }),
    rep(1),
    t("_wrapper(*args, **kwargs):", {
      "",
      "\t\tprint('",
    }),
    rep(1),
    t(": args={} kwargs={}'.format(fn.__name__, args, kwargs))", {
      "",
      "\t\treturn fn(*args, **kwargs)",
      "",
      "\treturn ",
    }),
    rep(1),
    t("_wrapper"),
    i(0),
  }),

  -- 🔹 Encapsulated property with getter/setter/deleter (FIXED: deleter has no 'value')
  s({ trig = "eprop", dscr = "@property with getter/setter/deleter" }, {
    t("@property", {
      "",
      "def ",
    }),
    i(1, "name"),
    t("(self):", {
      "",
      "\treturn self.__",
    }),
    rep(1),
    t({
      "",
      "@",
    }),
    rep(1),
    t(".setter", {
      "",
      "def ",
    }),
    rep(1),
    t("(self, value):", {
      "",
      "\tself.__",
    }),
    rep(1),
    t(" = value", {
      "",
      "@",
    }),
    rep(1),
    t(".deleter", {
      "",
      "def ",
    }),
    rep(1),
    t("(self):", { -- ✅ FIX: deleter takes only 'self', not 'value'
      "",
      "\tdel self.__",
    }),
    rep(1),
    i(0),
  }),

  s({ trig = "dataclass", dscr = "@dataclass with type hints" }, {
    t("from dataclasses import dataclass", {
      "",
      "",
      "@dataclass",
      "class ",
    }),
    i(1, "Name"),
    t(":", {
      "",
      "\t",
    }),
    i(2, "field: str"),
    t({
      "",
      "\t# add more fields here",
    }),
    i(0),
  }),

  s({ trig = "decparam", dscr = "Parameterized decorator (decorator with args)" }, {
    t("def "),
    i(1, "decorator"),
    t("(", i(2, "param"), "):", {
      "",
      "\tdef inner(func):",
      "",
      "\t\tdef wrapper(*args, **kwargs):",
      "",
      "\t\t\t",
    }),
    i(3, "# use param here"),
    t({
      "",
      "\t\t\treturn func(*args, **kwargs)",
      "",
      "\t\treturn wrapper",
      "",
      "\treturn inner",
    }),
    i(0),
  }),

  -- 🔹 Property with getter/setter/deleter (FIXED: deleter has no 'value')
  s({ trig = "prop1", dscr = "@property with getter/setter/deleter" }, {
    t("@property", { "", "def " }),
    i(1, "name"),
    t("(self):", {
      "",
      "\treturn self.",
    }),
    rep(1),
    t({
      "",
      "@",
    }),
    rep(1),
    t(".setter", {
      "",
      "def ",
    }),
    rep(1),
    t("(self, value):", {
      "",
      "\tself.",
    }),
    rep(1),
    t(" = value", {
      "",
      "@",
    }),
    rep(1),
    t(".deleter", {
      "",
      "def ",
    }),
    rep(1),
    t("(self):", { -- ✅ FIX: deleter takes only 'self', not 'value'
      "",
      "\tdel self.",
    }),
    rep(1),
    i(0),
  }),

  -- 🔹 Property with getter/setter only
  s({ trig = "prop2", dscr = "@property with getter/setter (no deleter)" }, {
    t("@property", { "", "def " }),
    i(1, "name"),
    t("(self):", {
      "",
      "\treturn self.",
    }),
    rep(1),
    t({
      "",
      "@",
    }),
    rep(1),
    t(".setter", {
      "",
      "def ",
    }),
    rep(1),
    t("(self, value):", {
      "",
      "\tself.",
    }),
    rep(1),
    t(" = value"),
    i(0),
  }),

  -- 🔹 Basic function decorator template
  s({ trig = "decbasic", dscr = "Basic function decorator with wrapper" }, {
    t("def "),
    i(1, "decorator_name"),
    t("(func):", {
      "",
      "\tdef wrapper(*args, **kwargs):",
      "",
      "\t\t",
    }),
    i(2, "# before call"),
    t({
      "",
      "\t\tresult = func(*args, **kwargs)",
      "",
      "\t\t",
    }),
    i(3, "# after call"),
    t({
      "",
      "\t\treturn result",
      "",
      "\treturn wrapper",
    }),
    i(0),
  }),

  -- 🔹 Decorator with *args/**kwargs + example usage
  s({ trig = "decargs", dscr = "Decorator with *args/**kwargs + @decorator example" }, {
    t("def "),
    i(1, "decorator_name"),
    t("(func):", {
      "",
      "\tdef wrapper(*args, **kwargs):",
      "",
      "\t\tprint('I have arguments of original function')",
      "",
      "\t\tprint('args:', args)",
      "",
      "\t\tprint('kwargs:', kwargs)",
      "",
      "\t\tprint('I can do anything with them and then execute the original function')",
      "",
      "\t\treturn func(*args, **kwargs)",
      "",
      "\treturn wrapper",
      "",
      "",
      "@",
    }),
    rep(1),
    t({
      "",
      "def ",
    }),
    i(2, "function_name"),
    t("("),
    i(3, "arg1"),
    t(", "),
    i(4, "arg2"),
    t("):", {
      "",
      "\t",
    }),
    i(5, "print('function body')"),
    i(0),
  }),

  -- 🔹 Simple decorator (no arguments)
  s({ trig = "decsimple", dscr = "Simple decorator without arguments + usage" }, {
    t("def "),
    i(1, "decorator_name"),
    t("(original_function):", {
      "",
      "\tdef wrapper_function():",
      "",
      "\t\t",
    }),
    i(2, "print('extra stuff before')"),
    t({
      "",
      "\t\treturn original_function()",
      "",
      "\treturn wrapper_function",
      "",
      "",
      "@",
    }),
    rep(1),
    t({
      "",
      "def ",
    }),
    i(3, "function_name"),
    t("():", {
      "",
      "\t",
    }),
    i(4, "print('function body')"),
    i(0),
  }),

  -- 🔹 Decorator with parameters
  s({ trig = "decparams", dscr = "Decorator with parameters + usage example" }, {
    t("def "),
    i(1, "decorator_with_params"),
    t("("),
    i(2, "param1"),
    t(", "),
    i(3, "param2"),
    t("):", {
      "",
      "\tdef decorator(func):",
      "",
      "\t\tdef wrapper(*args, **kwargs):",
      "",
      "\t\t\t",
    }),
    i(4, "# code with decorator params"),
    t({
      "",
      "\t\t\tprint(f'Decorator params: {",
    }),
    rep(2),
    t("}, {"),
    rep(3),
    t("}')", {
      "",
      "\t\t\treturn func(*args, **kwargs)",
      "",
      "\t\treturn wrapper",
      "",
      "\treturn decorator",
      "",
      "",
      "@",
    }),
    rep(1),
    t("("),
    i(5, "arg1"),
    t(", "),
    i(6, "arg2"),
    t(")", {
      "",
      "def ",
    }),
    i(7, "function_name"),
    t("("),
    i(8, "arg"),
    t("):", {
      "",
      "\t",
    }),
    i(9, "pass"),
    i(0),
  }),

  -- 🔹 Class-based decorator (__call__)
  s({ trig = "decclass", dscr = "Class-based decorator using __call__" }, {
    t("class "),
    i(1, "DecoratorClass"),
    t(":", {
      "",
      "\tdef __init__(self, func):",
      "",
      "\t\tself.func = func",
      "",
      "\t\t",
    }),
    i(2, "# initialization"),
    t({
      "",
      "",
      "\tdef __call__(self, *args, **kwargs):",
      "",
      "\t\t",
    }),
    i(3, "# before call"),
    t({
      "",
      "\t\tresult = self.func(*args, **kwargs)",
      "",
      "\t\t",
    }),
    i(4, "# after call"),
    t({
      "",
      "\t\treturn result",
      "",
      "",
      "@",
    }),
    rep(1),
    t({
      "",
      "def ",
    }),
    i(5, "function_name"),
    t("("),
    i(6, "arg"),
    t("):", {
      "",
      "\t",
    }),
    i(7, "pass"),
    i(0),
  }),

  -- 🔹 Decorator with @functools.wraps
  s({ trig = "decwraps", dscr = "Decorator with @wraps to preserve metadata" }, {
    t({
      "from functools import wraps",
      "",
      "def ",
    }),
    i(1, "decorator_name"),
    t("(func):", {
      "",
      "\t@wraps(func)",
      "",
      "\tdef wrapper(*args, **kwargs):",
      "",
      "\t\t",
    }),
    i(2, "# before call"),
    t({
      "",
      "\t\tresult = func(*args, **kwargs)",
      "",
      "\t\t",
    }),
    i(3, "# after call"),
    t({
      "",
      "\t\treturn result",
      "",
      "\treturn wrapper",
    }),
    i(0),
  }),

  -- 🔹 Async decorator with @functools.wraps
  s({ trig = "decasync", dscr = "Async decorator with @wraps + usage example" }, {
    t({
      "import functools",
      "",
      "def ",
    }),
    i(1, "async_decorator"),
    t("(func):", {
      "",
      "\t@functools.wraps(func)",
      "",
      "\tasync def wrapper(*args, **kwargs):",
      "",
      "\t\t",
    }),
    i(2, "# before await"),
    t({
      "",
      "\t\tresult = await func(*args, **kwargs)",
      "",
      "\t\t",
    }),
    i(3, "# after await"),
    t({
      "",
      "\t\treturn result",
      "",
      "\treturn wrapper",
      "",
      "",
      "@",
    }),
    rep(1),
    t({
      "",
      "async def ",
    }),
    i(4, "async_function"),
    t("("),
    i(5, "arg"),
    t("):", {
      "",
      "\t",
    }),
    i(6, "pass"),
    i(0),
  }),

  -- 🔹 @property with getter/setter/deleter (using _name convention)
  s({ trig = "propdec", dscr = "@property with getter/setter/deleter (_name convention)" }, {
    t("@property", { "", "def " }),
    i(1, "name"),
    t("(self):", {
      "",
      "\t",
    }),
    i(2, "return self._"),
    rep(1),
    t({
      "",
      "",
      "@",
    }),
    rep(1),
    t(".setter", {
      "",
      "def ",
    }),
    rep(1),
    t("(self, value):", {
      "",
      "\t",
    }),
    i(3, "self._"),
    rep(1),
    t(" = value", {
      "",
      "",
      "@",
    }),
    rep(1),
    t(".deleter", {
      "",
      "def ",
    }),
    rep(1),
    t("(self):", {
      "",
      "\t",
    }),
    i(4, "del self._"),
    rep(1),
    i(0),
  }),

  -- 🔹 @staticmethod decorator
  s({ trig = "staticdec", dscr = "@staticmethod for class methods" }, {
    t("@staticmethod", {
      "",
      "def ",
    }),
    i(1, "name"),
    t("("),
    i(2, "args"),
    t("):", {
      "",
      "\t",
    }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 @classmethod decorator
  s({ trig = "classdec", dscr = "@classmethod for class methods with cls" }, {
    t("@classmethod", {
      "",
      "def ",
    }),
    i(1, "name"),
    t("(cls, "),
    i(2, "args"),
    t("):", {
      "",
      "\t",
    }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 Stack multiple decorators
  s({ trig = "decstack", dscr = "Stack multiple decorators on a function" }, {
    t("@"),
    i(1, "decorator_one"),
    t({
      "",
      "@",
    }),
    i(2, "decorator_two"),
    t({
      "",
      "@",
    }),
    i(3, "decorator_three"),
    t({
      "",
      "def ",
    }),
    i(4, "function_name"),
    t("("),
    i(5, "args"),
    t("):", {
      "",
      "\t",
    }),
    i(6, "pass"),
    i(0),
  }),

  -- 🔹 Logging decorator with try/except
  s({ trig = "declog", dscr = "Logging decorator with try/except error handling" }, {
    t({
      "import logging",
      "",
      "def ",
    }),
    i(1, "log_decorator"),
    t("(func):", {
      "",
      "\tdef wrapper(*args, **kwargs):",
      "",
      "\t\tlogging.info(f'Calling {func.__name__} with args={args}, kwargs={kwargs}')",
      "",
      "\t\ttry:",
      "",
      "\t\t\tresult = func(*args, **kwargs)",
      "",
      "\t\t\tlogging.info(f'{func.__name__} returned {result}')",
      "",
      "\t\t\treturn result",
      "",
      "\t\texcept Exception as e:",
      "",
      "\t\t\tlogging.error(f'{func.__name__} raised {e}')",
      "",
      "\t\t\traise",
      "",
      "\treturn wrapper",
    }),
    i(0),
  }),

  -- 🔹 Timing decorator with @wraps
  s({ trig = "dectime", dscr = "Timing decorator to measure function execution time" }, {
    t({
      "import time",
      "from functools import wraps",
      "",
      "def ",
    }),
    i(1, "timing_decorator"),
    t("(func):", {
      "",
      "\t@wraps(func)",
      "",
      "\tdef wrapper(*args, **kwargs):",
      "",
      "\t\tstart = time.time()",
      "",
      "\t\tresult = func(*args, **kwargs)",
      "",
      "\t\tend = time.time()",
      "",
      "\t\tprint(f'{func.__name__} executed in {end - start:.4f} seconds')",
      "",
      "\t\treturn result",
      "",
      "\treturn wrapper",
    }),
    i(0),
  }),

  -- 🔹 Simple memoization/cache decorator
  s({ trig = "deccache", dscr = "Simple memoization decorator (args-only cache)" }, {
    t({
      "from functools import wraps",
      "",
      "def ",
    }),
    i(1, "cache_decorator"),
    t("(func):", {
      "",
      "\tcache = {}",
      "",
      "\t@wraps(func)",
      "",
      "\tdef wrapper(*args):",
      "",
      "\t\tif args not in cache:",
      "",
      "\t\t\tcache[args] = func(*args)",
      "",
      "\t\treturn cache[args]",
      "",
      "\treturn wrapper",
    }),
    i(0),
  }),

  -- 🔹 Retry decorator with configurable attempts and delay
  s({ trig = "decretry", dscr = "Retry decorator with max_attempts and delay params" }, {
    t({
      "import time",
      "from functools import wraps",
      "",
      "def ",
    }),
    i(1, "retry_decorator"),
    t("(max_attempts="),
    i(2, "3"),
    t(", delay="),
    i(3, "1.0"),
    t("):", {
      "",
      "\tdef decorator(func):",
      "",
      "\t\t@wraps(func)",
      "",
      "\t\tdef wrapper(*args, **kwargs):",
      "",
      "\t\t\tfor attempt in range(max_attempts):",
      "",
      "\t\t\t\ttry:",
      "",
      "\t\t\t\t\treturn func(*args, **kwargs)",
      "",
      "\t\t\t\texcept Exception as e:",
      "",
      "\t\t\t\t\tif attempt == max_attempts - 1:",
      "",
      "\t\t\t\t\t\traise",
      "",
      "\t\t\t\t\tprint(f'Attempt {attempt + 1} failed: {e}. Retrying...')",
      "",
      "\t\t\t\t\ttime.sleep(delay)",
      "",
      "\t\treturn wrapper",
      "",
      "\treturn decorator",
    }),
    i(0),
  }),

  -- 🔹 Full try/except/else/finally block with comments
  s({ trig = "tryfull", dscr = "Full try/except/else/finally with comments" }, {
    t({ "try:", "\t" }),
    i(1, "# code that may raise"),
    t({ "", "\t" }),
    i(2, "print('Just Before Error.')"),
    t({ "", "\t" }),
    i(3, "x = x + 2"),
    t("  # example error", { "", "\t" }),
    i(4, "print('This won\\'t run if error above')"),
    t({ "", "\t" }),
    i(5, "x = 5"),
    t({ "", "except " }),
    i(6, "Exception"),
    t(" as "),
    i(7, "e"),
    t(":", { "", "\t" }),
    i(8, "print('In Except Block. Try didn\\'t work!')"),
    t({ "", "\t" }),
    i(9, "# handle error"),
    t({ "", "\t" }),
    i(10, "x = 2"),
    t({ "", "else:", "\t" }),
    i(11, "# runs if no exception"),
    t({ "", "\t" }),
    i(12, "x = 23"),
    t({ "", "\t" }),
    i(13, "print('In Else Block. Runs only when no exception')"),
    t({ "", "finally:", "\t" }),
    i(14, "# always runs"),
    t({ "", "\t" }),
    i(15, "print('In Finally Block value of x =', x)"),
    i(0),
  }),

  -- 🔹 Simple try/except catch-all
  s({ trig = "tryex", dscr = "Simple try/except with catch-all handler" }, {
    t({ "try:", "\t" }),
    i(1, "# code"),
    t({ "", "\t" }),
    i(2, "pass"),
    t({ "", "except:", "\t" }),
    i(3, "print('Error occurred!')"),
    t({ "", "\t" }),
    i(4, "pass"),
    i(0),
  }),

  -- 🔹 Multiple specific exception handlers
  s({ trig = "trymulti", dscr = "Try with multiple specific exception handlers" }, {
    t({ "try:", "\t" }),
    i(1, "# code that may raise different errors"),
    t({ "", "\t" }),
    i(2, "import unknown_module"),
    t("  # ImportError", { "", "\t" }),
    i(3, "print(1 / 0)"),
    t("  # ZeroDivisionError", { "", "\t" }),
    i(4, "number = int(input('Enter a number: '))"),
    t("  # ValueError", { "", "\t" }),
    i(5, "file_object = open('unnamed_file.txt', 'r')"),
    t("  # IOError", {
      "",
      "except ImportError:",
      "\t",
    }),
    i(6, "print('Raised ImportError! An import statement failed.')"),
    t({ "", "except ZeroDivisionError:", "\t" }),
    i(7, 'print("Raised ZeroDivisionError! You can\'t divide by zero.")'),
    t({ "", "except ValueError:", "\t" }),
    i(8, "print('Raised ValueError! Integer Numbers only')"),
    t({ "", "except IOError:", "\t" }),
    i(9, "print('An error occurred trying to read the file.')"),
    t({ "", "except Exception as " }),
    i(10, "e"),
    t(":", { "", "\t" }),
    i(11, "print('Some Error Occurred!', e)"),
    i(0),
  }),

  -- 🔹 Try/except with 'as' to capture exception object
  s({ trig = "tryas", dscr = "Try/except with 'as' to capture exception object" }, {
    t({ "try:", "\t" }),
    i(1, "# code"),
    t({ "", "\t" }),
    i(2, "pass"),
    t({ "", "except " }),
    i(3, "Exception"),
    t(" as "),
    i(4, "e"),
    t(":", { "", "\t" }),
    i(5, "print(f'Error: {e}')"),
    t({ "", "\t" }),
    i(6, "pass"),
    i(0),
  }),

  -- 🔹 Try/finally block (without except)
  s({ trig = "tryfin", dscr = "Try/finally block (guaranteed cleanup)" }, {
    t({ "try:", "\t" }),
    i(1, "# код"),
    t({ "", "\t" }),
    i(2, "pass"),
    t({ "", "finally:", "\t" }),
    i(3, "# виконується завжди (навіть якщо є помилка)"),
    t({ "", "\t" }),
    i(4, "pass"),
    i(0),
  }),

  -- 🔹 Try/except/else block (without finally)
  s({ trig = "tryelse", dscr = "Try/except/else block (runs else if no exception)" }, {
    t({ "try:", "\t" }),
    i(1, "# код"),
    t({ "", "\t" }),
    i(2, "pass"),
    t({ "", "except " }),
    i(3, "Exception"),
    t(" as "),
    i(4, "e"),
    t(":", { "", "\t" }),
    i(5, "print(f'Error: {e}')"),
    t({ "", "else:", "\t" }),
    i(6, "# виконується, якщо не було винятку"),
    t({ "", "\t" }),
    i(7, "pass"),
    i(0),
  }),

  -- 🔹 Context manager with try/finally
  s({ trig = "withtry", dscr = "Context manager + try/finally for resource cleanup" }, {
    t("with open("),
    i(1, "'file.txt'"),
    t(", "),
    i(2, "'r'"),
    t(") as "),
    i(3, "f"),
    t(":", {
      "",
      "\ttry:",
      "",
      "\t\t",
    }),
    i(4, "data = f.read()"),
    t({ "", "\t\t" }),
    i(5, "# обробка даних"),
    t({ "", "\tfinally:", "\t\t" }),
    i(6, "# гарантоване закриття, якщо потрібно"),
    t({ "", "\t\t" }),
    i(7, "pass"),
    i(0),
  }),

  -- 🔹 Raise custom exception
  s({ trig = "raise", dscr = "Raise a custom exception" }, {
    t("raise "),
    i(1, "Exception"),
    t("("),
    i(2, "'Custom error message'"),
    t(")"),
    i(0),
  }),

  -- 🔹 Try/except with traceback printing
  s({ trig = "trytb", dscr = "Try/except with traceback.print_exc() for debugging" }, {
    t({ "import traceback", "", "try:", "\t" }),
    i(1, "# код"),
    t({ "", "\t" }),
    i(2, "pass"),
    t({ "", "except " }),
    i(3, "Exception"),
    t(" as "),
    i(4, "e"),
    t(":", { "", "\t" }),
    i(5, "print(f'Error: {e}')"),
    t({ "", "\t" }),
    i(6, "traceback.print_exc()  # повний стек викликів"),
    i(0),
  }),

  -- 🔹 Try/except with logging.error + exc_info
  s({ trig = "trylog", dscr = "Try/except with logging.error and full traceback" }, {
    t({ "import logging", "", "try:", "\t" }),
    i(1, "# код"),
    t({ "", "\t" }),
    i(2, "pass"),
    t({ "", "except " }),
    i(3, "Exception"),
    t(" as "),
    i(4, "e"),
    t(":", { "", "\t" }),
    t("logging.error(f'Error in "),
    i(5, "func_name"),
    t(": {e}', exc_info=True)"),
    t({ "", "\t" }),
    i(6, "raise"),
    t("  # re-raise if needed"),
    i(0),
  }),

  -- 🔹 List comprehension (reordered for logical Tab navigation: iterable → item → expr)
  s({ trig = "lc", dscr = "List comprehension: [expr for item in iterable]" }, {
    t("["),
    i(3, "expr"),
    t(" for "),
    i(2, "item"),
    t(" in "),
    i(1, "iterable"),
    t("]"),
    i(0),
  }),

  -- 🔹 List comprehension with if-else (reordered for logical Tab navigation)
  s({ trig = "lcie", dscr = "List comprehension with if-else: [true if cond else false for item in iter]" }, {
    t("["),
    i(3, "true_val"),
    t(" if "),
    i(4, "condition"),
    t(" else "),
    i(5, "false_val"),
    t(" for "),
    i(2, "item"),
    t(" in "),
    i(1, "iterable"),
    t("]"),
    i(0),
  }),

  -- 🔹 List comprehension with if filter
  s({ trig = "lci", dscr = "List comprehension: [expr for x in iter if cond]" }, {
    t("["),
    i(3, "expr"),
    t(" for "),
    i(2, "item"),
    t(" in "),
    i(1, "iterable"),
    t(" if "),
    i(4, "condition"),
    t("]"),
    i(0),
  }),

  -- 🔹 Dictionary comprehension
  s({ trig = "dc", dscr = "Dict comprehension: {k:v for k,v in iter}" }, {
    t("{"),
    i(4, "out_key"),
    t(": "),
    i(5, "out_val"),
    t(" for "),
    i(2, "k"),
    t(", "),
    i(3, "v"),
    t(" in "),
    i(1, "iterable"),
    t("}"),
    i(0),
  }),

  -- 🔹 Dictionary comprehension with if filter
  s({ trig = "dci", dscr = "Dict comprehension with filter: {k:v for k,v in iter if cond}" }, {
    t("{"),
    i(4, "out_key"),
    t(": "),
    i(5, "out_val"),
    t(" for "),
    i(2, "k"),
    t(", "),
    i(3, "v"),
    t(" in "),
    i(1, "iterable"),
    t(" if "),
    i(6, "condition"),
    t("}"),
    i(0),
  }),

  -- 🔹 Set comprehension
  s({ trig = "sc", dscr = "Set comprehension: {expr for x in iter}" }, {
    t("{"),
    i(3, "expr"),
    t(" for "),
    i(2, "item"),
    t(" in "),
    i(1, "iterable"),
    t("}"),
    i(0),
  }),

  -- 🔹 Set comprehension with if filter
  s({ trig = "sci", dscr = "Set comprehension with filter: {expr for x in iter if cond}" }, {
    t("{"),
    i(3, "expr"),
    t(" for "),
    i(2, "item"),
    t(" in "),
    i(1, "iterable"),
    t(" if "),
    i(4, "condition"),
    t("}"),
    i(0),
  }),

  -- 🔹 Generator expression
  s({ trig = "gc", dscr = "Generator expression: (expr for x in iter)" }, {
    t("("),
    i(3, "expr"),
    t(" for "),
    i(2, "item"),
    t(" in "),
    i(1, "iterable"),
    t(")"),
    i(0),
  }),

  -- 🔹 Generator comprehension with if filter
  s({ trig = "gci", dscr = "Generator with filter: (expr for x in iter if cond)" }, {
    t("("),
    i(3, "expr"),
    t(" for "),
    i(2, "item"),
    t(" in "),
    i(1, "iterable"),
    t(" if "),
    i(4, "condition"),
    t(")"),
    i(0),
  }),

  -- 🔹 Python shebang line
  s({ trig = "shebang", dscr = "#!/usr/bin/env python shebang" }, {
    t("#!/usr/bin/env python"),
    i(0),
  }),

  -- 🔹 Pyright ignore directive
  s({ trig = "#ignore", dscr = "# pyright: ignore[CODE] directive" }, {
    t("# pyright: ignore["),
    i(1, "error_code"),
    t("]"),
    i(0),
  }),

  s({ trig = "s1", dscr = 'Multiline string """..."""' }, {
    t('"""'),
    i(0),
    t('"""'),
  }),

  -- 🔹 One-line multiline string
  s({ trig = "s2", dscr = 'Inline docstring """..."""' }, {
    t('"""'),
    i(0),
    t('"""'),
  }),

  -- ⚠️ WARNING: 's' is extremely short and will likely conflict with LSP/CMP
  -- 🔹 self reference
  s({ trig = "s3", dscr = "self. attribute access" }, {
    t("self."),
    i(0),
  }),

  -- 🔹 Magic method (dunder)
  s({ trig = "dunder", dscr = "Magic method __...__" }, {
    t("__"),
    i(1, "init"),
    t("__"),
    i(0),
  }),

  -- 🔹 if __name__ == "__main__" entry point
  s({ trig = "ifmain", dscr = "if __name__ == '__main__' block" }, {
    t({ 'if __name__ == "__main__":', "\t" }),
    i(1, "main()"),
    i(0),
  }),

  -- 🔹 Import module
  s({ trig = "imp", dscr = "import module statement" }, {
    t("import "),
    i(1, "module"),
    i(0),
  }),

  -- 🔹 from ... import ...
  s({ trig = "fromim", dscr = "from ... import ... statement" }, {
    t("from "),
    i(1, "module"),
    t(" import "),
    i(2, "Object"),
    i(0),
  }),

  -- 🔹 if statement
  s({ trig = "py-if", dscr = "if condition: statement" }, {
    t("if "),
    i(1, "condition"),
    t({ ":", "\t" }),
    i(2, "pass"),
    i(0),
  }),

  -- 🔹 elif statement
  s({ trig = "py-elif", dscr = "elif condition: statement" }, {
    t("elif "),
    i(1, "condition"),
    t({ ":", "\t" }),
    i(2, "pass"),
    i(0),
  }),

  -- 🔹 else block
  s({ trig = "py-else", dscr = "else: block" }, {
    t({ "else:", "\t" }),
    i(1, "pass"),
    i(0),
  }),

  -- 🔹 if/else statement
  s({ trig = "ifelse", dscr = "if/else conditional block" }, {
    t("if "),
    i(1, "condition"),
    t({ ":", "\t" }),
    i(2, "pass"),
    t({ "", "else:", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 match/case statement (Python 3.10+)
  s({ trig = "match", dscr = "match/case structural pattern matching" }, {
    t("match "),
    i(1, "expression"),
    t({ ":", "\tcase " }),
    i(2, "pattern"),
    t({ ":", "\t\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 case block
  s({ trig = "case", dscr = "case block for match statement" }, {
    t("case "),
    i(1, "pattern"),
    t({ ":", "\t" }),
    i(2, "pass"),
    i(0),
  }),

  -- 🔹 case wildcard (catch-all)
  s({ trig = "casew", dscr = "case _ wildcard block (default fallback)" }, {
    t({ "case _:", "\t" }),
    i(1, "pass"),
    i(0),
  }),

  -- 🔹 while loop
  s({ trig = "while", dscr = "while loop" }, {
    t("while "),
    i(1, "condition"),
    t({ ":", "\t" }),
    i(2, "pass"),
    i(0),
  }),

  -- 🔹 for loop
  s({ trig = "for", dscr = "for loop over iterable" }, {
    t("for "),
    i(1, "item"),
    t(" in "),
    i(2, "iterable"),
    t({ ":", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 for loop with range()
  s({ trig = "forr", dscr = "for loop over range()" }, {
    t("for "),
    i(1, "i"),
    t(" in range("),
    i(2, "stop"),
    t("):", { "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 with statement (context manager)
  s({ trig = "with", dscr = "with statement for resource management" }, {
    t("with "),
    i(1, "expression"),
    t(" as "),
    i(2, "target"),
    t({ ":", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 lambda anonymous function
  s({ trig = "lambda", dscr = "lambda anonymous function" }, {
    t("lambda "),
    i(1, "args"),
    t(": "),
    i(2, "expression"),
    i(0),
  }),

  -- 🔹 Function definition
  s({ trig = "def", dscr = "Function definition" }, {
    t("def "),
    i(1, "fname"),
    t("("),
    i(2, "args"),
    t("):", { "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 Function with return type hint
  s({ trig = "deft", dscr = "Function definition with return type" }, {
    t("def "),
    i(1, "fname"),
    t("("),
    i(2, "args"),
    t(") -> "),
    i(3, "None"),
    t(":", { "", "\t" }),
    i(4, "pass"),
    i(0),
  }),

  -- 🔹 Class definition
  s({ trig = "class", dscr = "Class definition" }, {
    t("class "),
    i(1, "ClassName"),
    t(":", { "", "\t" }),
    i(2, "pass"),
    i(0),
  }),

  -- 🔹 Derived class (inheritance)
  s({ trig = "classd", dscr = "Class definition with inheritance" }, {
    t("class "),
    i(1, "ClassName"),
    t("("),
    i(2, "BaseClass"),
    t("):", { "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 Full class template (__init__, docstring, super, self assignment)
  s({ trig = "classi", dscr = "Class template with __init__, docstring & super()" }, {
    t("class "),
    i(1, "ClassName"),
    t("("),
    i(2, "BaseClass"),
    t("):", {
      "",
      '\t""" ',
    }),
    i(3, "docstring"),
    t(' """', {
      "",
      "\tdef __init__(self, ",
    }),
    i(4, "arg"),
    t("):", {
      "",
      "\t\t",
    }),
    t("super("),
    rep(1),
    t(", self).__init__()", {
      "",
      "\t\tself.",
    }),
    rep(4),
    t(" = "),
    rep(4),
    i(0),
  }),

  -- 🔹 Class method definition
  s({ trig = "defs", dscr = "Class method definition (def mname(self, ...))" }, {
    t("def "),
    i(1, "mname"),
    t("(self"),
    i(2, ", args"),
    t("):", { "", "\t" }),
    i(3, "pass"),
    i(0),
  }),

  -- 🔹 Class method with return type hint
  s({ trig = "defst", dscr = "Class method with return type hint" }, {
    t("def "),
    i(1, "mname"),
    t("(self"),
    i(2, ", args"),
    t(") -> "),
    i(3, "None"),
    t(":", { "", "\t" }),
    i(4, "pass"),
    i(0),
  }),

  -- 🔹 Property template (getter + setter with linked names)
  s({ trig = "property", dscr = "New property: get and set via @property decorator" }, {
    t("@property", { "", "def " }),
    i(1, "pname"),
    t("(self):", { "", '\t"""The ' }),
    rep(1),
    t(' property. """', { "", "\t" }),
    t("return self._"),
    rep(1),
    t({
      "",
      "",
      "@",
    }),
    rep(1),
    t(".setter", {
      "",
      "def ",
    }),
    rep(1),
    t("(self, value):", {
      "",
      "\tself._",
    }),
    rep(1),
    t(" = value"),
    i(0),
  }),

  -- 🔹 except statement
  s({ trig = "except", dscr = "except statement (catch specific exceptions)" }, {
    t("except "),
    i(1, "Exception"),
    t({ ":", "\t" }),
    i(2, "pass"),
    i(0),
  }),

  -- 🔹 except as statement
  s({ trig = "exceptas", dscr = "except as statement (capture exception object)" }, {
    t("except "),
    i(1, "Exception"),
    t(" as "),
    i(2, "e"),
    t({ ":", "\t" }),
    t("raise "),
    rep(2),
    i(0),
  }),

  -- 🔹 try/except block
  s({ trig = "try", dscr = "try/except blocks" }, {
    t({ "try:", "\t" }),
    i(1, "pass"),
    t({ "", "except " }),
    i(2, "Exception"),
    t(" as "),
    i(3, "e"),
    t({ ":", "\t" }),
    t("raise "),
    rep(3),
    i(0),
  }),

  -- 🔹 try/except/else block
  s({ trig = "trya", dscr = "try/except/else blocks" }, {
    t({ "try:", "\t" }),
    i(1, "# code"),
    t({ "", "except " }),
    i(2, "Exception"),
    t(" as "),
    i(3, "e"),
    t(":", { "", "\t" }),
    i(4, "raise e  # or handle error"),
    t({ "", "else:", "\t" }),
    i(5, "# runs if no exception"),
    i(0),
  }),

  -- 🔹 try/except/finally block
  s({ trig = "tryf", dscr = "try/except/finally blocks" }, {
    t({ "try:", "\t" }),
    i(1, "# code"),
    t({ "", "except " }),
    i(2, "Exception"),
    t(" as "),
    i(3, "e"),
    t(":", { "", "\t" }),
    i(4, "raise e  # or handle error"),
    t({ "", "finally:", "\t" }),
    i(5, "# always runs"),
    i(0),
  }),

  -- 🔹 try/except/else/finally block (full structure)
  s({ trig = "tryef", dscr = "Full try/except/else/finally structure" }, {
    t({ "try:", "\t" }),
    i(1, "# code"),
    t({ "", "except " }),
    i(2, "Exception"),
    t(" as "),
    i(3, "e"),
    t(":", { "", "\t" }),
    i(4, "raise e  # or handle error"),
    t({ "", "else:", "\t" }),
    i(5, "# runs if no exception"),
    t({ "", "finally:", "\t" }),
    i(6, "# always runs"),
    i(0),
  }),
  -- 🔹 Jupyter code cell
  s({ trig = "#cell", dscr = "Jupyter code cell marker (# %%)" }, {
    t("# %%"),
    i(0),
  }),

  -- 🔹 Jupyter markdown cell
  s({ trig = "#mark", dscr = "Jupyter markdown cell marker (# %% [markdown])" }, {
    t("# %% [markdown]"),
    i(0),
  }),

  -- 🔹 self.assertEqual
  s({ trig = "ase", dscr = "unittest: assertEqual(expected, actual, msg)" }, {
    t("self.assertEqual("),
    i(1, "expected"),
    t(", "),
    i(2, "actual"),
    t(", "),
    i(3, "'message'"),
    t(")"),
    i(0),
  }),

  -- 🔹 self.assertNotEqual
  s({ trig = "asne", dscr = "unittest: assertNotEqual(expected, actual, msg)" }, {
    t("self.assertNotEqual("),
    i(1, "expected"),
    t(", "),
    i(2, "actual"),
    t(", "),
    i(3, "'message'"),
    t(")"),
    i(0),
  }),

  -- 🔹 self.assertRaises
  s({ trig = "asr", dscr = "unittest: assertRaises(exception, callable, args)" }, {
    t("self.assertRaises("),
    i(1, "Exception"),
    t(", "),
    i(2, "func"),
    t(", "),
    i(3, "arg"),
    t(")"),
    i(0),
  }),

  -- 🔹 self.assertTrue
  s({ trig = "ast", dscr = "unittest: assertTrue(condition, msg)" }, {
    t("self.assertTrue("),
    i(1, "condition"),
    t(", "),
    i(2, "'message'"),
    t(")"),
    i(0),
  }),

  -- 🔹 self.assertFalse
  s({ trig = "asf", dscr = "unittest: assertFalse(condition, msg)" }, {
    t("self.assertFalse("),
    i(1, "condition"),
    t(", "),
    i(2, "'message'"),
    t(")"),
    i(0),
  }),

  -- 🔹 self.assertIs
  s({ trig = "asi", dscr = "unittest: assertIs(expected, actual, msg)" }, {
    t("self.assertIs("),
    i(1, "expected"),
    t(", "),
    i(2, "actual"),
    t(", "),
    i(3, "'message'"),
    t(")"),
    i(0),
  }),

  -- 🔹 self.assertIsNot
  s({ trig = "asint", dscr = "unittest: assertIsNot(expected, actual, msg)" }, {
    t("self.assertIsNot("),
    i(1, "expected"),
    t(", "),
    i(2, "actual"),
    t(", "),
    i(3, "'message'"),
    t(")"),
    i(0),
  }),

  -- 🔹 self.assertIsNone
  s({ trig = "asino", dscr = "unittest: assertIsNone(obj, msg)" }, {
    t("self.assertIsNone("),
    i(1, "obj"),
    t(", "),
    i(2, "'message'"),
    t(")"),
    i(0),
  }),

  -- 🔹 self.assertIsNotNone
  s({ trig = "asinno", dscr = "unittest: assertIsNotNone(obj, msg)" }, {
    t("self.assertIsNotNone("),
    i(1, "obj"),
    t(", "),
    i(2, "'message'"),
    t(")"),
    i(0),
  }),

  -- 🔹 self.assertIn
  s({ trig = "asin", dscr = "unittest: assertIn(needle, haystack, msg)" }, {
    t("self.assertIn("),
    i(1, "needle"),
    t(", "),
    i(2, "haystack"),
    t(", "),
    i(3, "'message'"),
    t(")"),
    i(0),
  }),

  -- 🔹 self.assertNotIn
  s({ trig = "asni", dscr = "unittest: assertNotIn(needle, haystack, msg)" }, {
    t("self.assertNotIn("),
    i(1, "needle"),
    t(", "),
    i(2, "haystack"),
    t(", "),
    i(3, "'message'"),
    t(")"),
    i(0),
  }),

  -- 🔹 self.assert_ (⚠️ deprecated since Python 3.2, removed in 3.11+)
  s({ trig = "as", dscr = "unittest: assert_ (⚠️ deprecated, use assertTrue)" }, {
    t("self.assert_("),
    i(1, "condition"),
    t(", "),
    i(2, "'message'"),
    t(")"),
    i(0),
  }),

  -- 🔹 self.fail (force test failure)
  s({ trig = "fail", dscr = "unittest: fail(message) - force test to fail" }, {
    t("self.fail('"),
    i(1, "Test failed intentionally"),
    t("')"),
    i(0),
  }),
}
