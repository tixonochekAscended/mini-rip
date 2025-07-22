<div align="center">
  <img style="height: 250px;" src="https://raw.githubusercontent.com/tixonochekAscended/mini-rip/refs/heads/main/Mini-rip%20Logo%20Border%20Radiused.png">
</div>

------
# mini-rip — A minimal programming language.
**mini-rip** is a minimal, esoteric, interpreted programming language the official implementation of which is written in Lua. This project takes heavy inspiration from [T^ (TGlyph)](https://github.com/tixonochekAscended/TGlyph) — another programming language I made. To execute code, you as a programmer use special **sigils**, that are basically one-character symbols at the beginning of each line. Afterwards you pass arguments to that sigil to do certain actions. As I've just mentioned, the language is pretty minimal — however you can easily expand on it yourself so that is not a bad thing. If you are curious, in the source code you'll find a lexer, parser and an abstract executor.

## 🛠️ Installation
There are 3 main methods to install the **mini-rip** programming language.

1️⃣ **First Method**: Head into the **Releases** page of this repository. Afterwards, download an archive featuring a pre-built executable of **mini-rip** for your operating system and processor architecture. Extract that archive, make sure to put the executable in your PATH and enjoy programming in this wild language.

2️⃣ **Second Method**: If you don't trust my executables for some reason, fair enough. You can easily **build mini-rip from source** [by using Luanite](https://github.com/tixonochekAscended/luanite) - an amazing tool for working with **any Lua project**. Just create a new luanite project via `luanite init <DirectoryName>`, then copy the contents of the `src/` directory of this repository into the `app/` directory located inside of your newly created Luanite project and use `luanite build` to create a self-contained standalone executable of **mini-rip**. You should be aware that if you don't change the `name` property in your `luanite.project` file, the executable that you have built might be called `unspecified`, but you can just rename it to whatever you like.

3️⃣ **Third Method**: If you don't trust my executables _and_ Luanite for some reason, you can just use **mini-rip** through a **Lua 5.4.6** installation you got on your machine. Just run the `main.lua` file by using a command similar to `lua main.lua` and here you go - you can use mini-rip to execute `.mrip` files.

## ⚙️ Usage
If you have a **mini-rip executable** on your machine, you can easily run `.mrip` files written in **mini-rip** by using the following command:
```
mrip <FileName>
```
If you want to get more information regarding the **license of this project**, use `mrip license`.
### Read further if you are looking for a guide on how to program in the language itself.

-----
## 📜 Guide on mini-rip
Every single line of code in your `.mrip` file, excluding blank lines, must start with a **sigil**. A sigil is a one-character symbol located at the beginning of each line which decides what this line will do. There are assignment sigils that allow to create new containers (a container is basically a variable), arithmetic sigils that allow to perform math, label & goto sigils that allow to create loop-like before and many more other types of sigils. Each sigil must be followed by **arguments** - either a limited or an unlimited amount - each sigil _can_ have an assigned amount of minimal and maximum arguments. Here is a simple Hello World script with a variable:
```
@ message "Hello, World!\n"
! message
```
You might think that we first create a container and then put the string `Hello, World!\n` into it, but thats not what actually happens. **In mini-rip, there are no strings**. The only type that exists in our minimalistic language is a **number**. Also, the `@` sigil isn't creating a scalar variable (a scalar variable is basically a variable that contains a single numerical value) but is instead creating a **collection** of numbers. Each character of this string is converted to its **ASCII codepoint** first, then is appended to the collection called `message`. Remember - strings are basically syntatic sugar in mini-rip. Everything is a number under the hood. **Also, only integers exists. No floats for you!**

With that being said, let me mention that what splits different lines of code (commands) in mini-rip is just a newline character. No semicolons at the end of each line - that also means that you can't pair multiple commands on the same file-line. Sad, but managable. Now, let's go over each sigil in depth.

### `$` Sigil
**Minimum amount of arguments: `2`**, **maximum amount of arguments: `2`**. <br>
Initializes a scalar variable and sets its value. The first argument always should be an identifier, the second argument can be either an identifier or a number.
```
$ <VariableName> <VariableValue>
```

### `@` Sigil
**Minimum amount of arguments: `2`**. <br>
Initializes a collection variable and sets its values. The first argument always should be an identifier, can be followed by any amount of arguments, which can either be identifiers or numbers.
```
@ <VariableName> <FirstElement> <SecondElement> <ThirdElement> ...
```

### `#` Sigil
**Minimum amount of arguments: `1`**. <br>
Outputs each argument (which can be both identifiers and numbers) provided one by one to the terminal output as numbers. Doesn't convert anything to anything.
```
# <Number>
```
Outputs `<Number>`.

### `!` Sigil
**Minimum amount of arguments: `1`**. <br>
Outputs each argument (which can be both identifiers and numbers) provided one by one to the terminal output as characters. Treats each number provided to it as an ASCII codepoint and attempts to output that character. Doesn't output anything when given a negative value. These sequences are supported: `\n`, `\"`, `\t`, `\e`.
```
! <Number>
```
Outputs `<Character the ASCII codepoint of which is <Number>>`.

### `+` Sigil
**Minimum amount of arguments: `2`**. <br>
The first argument is always should be an identifier - an existing container. The second argument and the following ones can either be identifiers or numbers. This sigil first adds all arguments >2 together and then based on whether the container is a scalar or a collection performs a math operation on either the scalar's value or each member of a collection.
```
$ a 5
+ a 3

@ b 1 2 3 4 5 6 7 8 9 10
+ b 1 1
```
`a` here is `8`. 
The elements of `b` are the following: `3, 4, 5, 6, 7, 8, 9, 10, 11, 12`.

### `-` Sigil
**Minimum amount of arguments: `2`**. <br>
The first argument is always should be an identifier - an existing container. The second argument and the following ones can either be identifiers or numbers. This sigil first subtracts all arguments >2 together and then based on whether the container is a scalar or a collection performs a math operation on either the scalar's value or each member of a collection.
```
$ a 5
- a 8

@ b 1 2 3 4 5 6 7 8 9 10
- b 1 1
```
`a` here is `-3`. 
The elements of `b` are the following: `-1, 0, 1, 2, 3, 4, 5, 6, 7, 8`.

### `*` Sigil
**Minimum amount of arguments: `2`**, **maximum amount of arguments: `2`**. <br>
The first argument is always should be an identifier - an existing container. The second argument should be an identifier or a number - basically a multiplier. Performs multiplication on either the provided scalar's value of each member of the provided collection.
```
$ a 2
* a 4

```
`a` here is `8`. 

### `/` Sigil
**Minimum amount of arguments: `2`**, **maximum amount of arguments: `2`**. <br>
The first argument is always should be an identifier - an existing container. The second argument should be an identifier or a number. Performs division on either the provided scalar's value of each member of the provided collection.
```
$ a 10
/ a 2

```
`a` here is `5`. 

### `%` Sigil
**Minimum amount of arguments: `2`**, **maximum amount of arguments: `2`**. <br>
The first argument is always should be an identifier - an existing container. The second argument should be an identifier or a number. Performs division on either the provided scalar's value of each member of the provided collection and sets the scalar's value / member to the remainder of that division.
```
$ a 10
% a 3

```
`a` here is `1`. 

### `&` Sigil
**Minimum amount of arguments: `1`**, **maximum amount of arguments: `1`**. <br>
The first argument must be an identifiers. Creates a label that can be jumped to be `^` sigils. There is no need for this sigil to be located before a `^` sigil that wants to jump to the label created by it, because these label-creation sigils are handled before the execution of everything else.
```
& abc
! "steak\n"
^ abc

```
This code will output `steak` for the rest of eternity.

### `^` Sigil
**Minimum amount of arguments: `1`**, **maximum amount of arguments: `1`**. <br>
Jumps to a label created by the `&` sigil.
```
& abc
! "steak\n"
^ abc

```
This code will output `steak` for the rest of eternity.

### `?` Sigil
**Minimum amount of arguments: `2`**, **maximum amount of arguments: `2`**. <br>
A run-if sigil. Both arguments should always be either identifiers or numbers. The first argument is a pseudo-boolean: basically if its `1` then the next `N` lines (sigils) will be executed - if its any other value those lines won't be executed. `N` in this case is the second argument.
```
$ condition 0
$ applies_to_this_amount_of_sigils 2
? condition applies_to_this_amount_of_sigils
! "First print.\n"
! "Second print.\n"
! "Third print.\n"

```
Only `Third print.` gets outputted.

### `=` Sigil
**Minimum amount of arguments: `3`**, **maximum amount of arguments: `3`**. <br>
The first argument should be an identifier to a container where the result of the conditional operation will be written to (either `0` or `1`). Second and third arguments are either identifiers or numbers. If the second argument is equal to the third argument, sets the previously mentioned container to `1` (true), otherwise `0` (false).
```
= result 1 2
```
Here, `result` is `0` because `1` is not equal to `2`.

### `>` Sigil
**Minimum amount of arguments: `3`**, **maximum amount of arguments: `3`**. <br>
The first argument should be an identifier to a container where the result of the conditional operation will be written to (either `0` or `1`). Second and third arguments are either identifiers or numbers. If the second argument is greater than the third argument, sets the previously mentioned container to `1` (true), otherwise `0` (false).
```
> result 3 1
```
Here, `result` is `1` because `3` is greater than `1`.

### `<` Sigil
**Minimum amount of arguments: `3`**, **maximum amount of arguments: `3`**. <br>
The first argument should be an identifier to a container where the result of the conditional operation will be written to (either `0` or `1`). Second and third arguments are either identifiers or numbers. If the second argument is lesser than the third argument, sets the previously mentioned container to `1` (true), otherwise `0` (false).
```
< result 18 6
```
Here, `result` is `0` because `18` is not lesser than `6`.

### `:` Sigil
**Minimum amount of arguments: `3`**. <br>
The first argument should be an identifier to a container where the result of the conditional operation will be written to (either `0` or `1`). All arguments following the first one can either be identifiers or numbers. This is basically an `OR()` sigil - if at least one of the arguments provided (besides the first one) is equal to `1` (true), then the result of the cond. op. is `1`, otherwise `0`.
```
: result 0 5 -8 99 44 3 1 0
```
Here, `result` is `1` because **true** (`1`) is provided as one of the arguments to the sigil.

### `;` Sigil
**Minimum amount of arguments: `3`**. <br>
The first argument should be an identifier to a container where the result of the conditional operation will be written to (either `0` or `1`). All arguments following the first one can either be identifiers or numbers. This is basically an `ALL()` sigil - if at least one of the arguments provided (besides the first one) is not equal to `1`, then the result of the cond. op. is `0`, otherwise (if all arguments are truthful) `1`.
```
: result 1 1 1 1 1 1 1 1 0 1
```
Here, `result` is `0` because amongst all of these values there is one that is not equal to `1`.

### `|` Sigil
**Minimum amount of arguments: `1`**, **maximum amount of arguments: `1`**. <br>
The first and the only argument should be an identifier pointing to a container where the user input would be stored. This is basically an input sigil that prompts the user for an input. Remember that numbers inputted by the user are treated as ASCII characters and not actual numbers.
```
| a
! a
```
Prompts the user for input and then repeats what they said.

### `.` Sigil
**Minimum amount of arguments: `4`**, **maximum amount of arguments: `4`**. <br>
This is quite a versatile sigil that can do a lot of things. The first argument should be an identifier pointing to a container where the result will be stored. The second argument is an identifier pointing to an existing collection. The third argument should either be a number or an identifier - and is an index that is valid in the context of the collection mentioned as the second argument (collections in mini-rip are first-indexed as in Lua, so the first element is the first index). The fourth argument should either be a number or an identifier. If the fourth argument is equal to `1` (true), then the element at the provided index will be removed and stored in the result container (shifted, popped call it whatever you like), otherwise the element won't be removed and its value will just be stored in the result container.
```
@ a 3 4 5
. el 2 1

@ b 15 30 45
. el2 3 0
```
In this case:
- `a` is equal to `3, 5`
- `el` is equal to `4`
- `b` is equal to `15, 30, 45`
- `el2` is equal to `45`

-----
## ☎️ Community Projects & Forks, Contacting the developer, Contributing
Help is always greatly appreciated - you can use all of Github's features including issues, pull requests and more to contribute to **mini-rip**. If you would ever require any assistance regarding the **mini-rip** programming language or you would just like to join an official community, [we have a discord server.](https://discord.gg/NSK7YJ2R6j). We don't _usually_ speak English there, but we all can and will assist you or just talk to you about whatever you want in English. You can easily contact me as the developer there too.

Here is a list of featured projects (and github forks) regarding mini-rip that are for sure worth your attention:
- [mini-rip to JS transpiler, mini-rip to web](https://minirip-web.netlify.app/)
- [macro-rip, a fork of mini-rip with additional sigils](https://github.com/Ict00/macro_rip).

## 📝 Naming
If you are wondering why the language is called **mini-rip**, then I surely have an answer for you: I got no idea either. A thought just popped into my head a while ago with an idea for a programming language and some nonsensical name, which was **mini-rip**.

## 👨‍⚖️ License
**mini-rip** uses the GNU General Public License version 3. For more information, take a look at the `LICENSE` file and use the `mrip license` command.
