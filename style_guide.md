# Naming Style
| Type | Case |
| ---- | ----- |
File names | snake_case
Class names | PascalCase
Node names | PascalCase
Functions | snake_case
Variables | snake_case
Signals | snake_case (past tense)
Constants | CONSTANT_CASE
Enum names | PascalCase
Enum members | CONSTANT_CASE

# Variable order in script

```
01. @tool, @icon, @static_unload
02. class_name
03. extends
04. Documentation comments

05. signals
06. enums
07. constants
08. static variables
09. @export variables
10. remaining regular variables
11. @onready variables

12. _static_init()
13. remaining static methods
14. overridden built-in virtual methods:
	1. _init()
	2. _enter_tree()
	3. _ready()
	4. _process()
	5. _physics_process()
	6. remaining virtual methods
15. overridden custom methods
16. remaining methods
17. subclasses
```
