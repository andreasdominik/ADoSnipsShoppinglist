# ADoSnipsShoppinglist

Snips kill to manage a shopping list with Snips.ai.

This is a skill for the SnipsHermesQnD framework.

Language is German but the app-code is written using the multi-language
tools of the framework (with English already implemented) and can be adapted
to any language by adding the "sentences" and intents to the
database in a new language.

Please see the documentation of the framework for details:
[QnD Documentation](https://andreasdominik.github.io/ADoSnipsQnD/dev)

# Julia

This skill is (like the entire SnipsHermesQnD framework) written in the
modern programming language Julia (because Julia is faster
then Python and coding is much much easier and much more straight forward).
However "Pythonians" often need some time to get familiar with Julia.

If you are ready for the step forward, start here: https://julialang.org/


# Skill
## Actions

The skill provides intents to 
- add an item,
- delete an item,
- check, if an item is on the list,
- read the list,
- delete the list and
- print the list.

The list is stored as a file (and survives crash and reboot).

## Configuration `config.ini`

The following entries are read from the `config.ini`:

##### language=de
Default language is `de`. English is already implemented in the action code;
however English intents are missing.
New languages can be implemneted by just adding the necessary phrases
to the language database. To implement, add all translations to the
file `languages.jl` and make a merge request in the Githup project (or
just send me the translations and I will include them).

##### directory=ApplicationData
Directory in which the file is stored. `directory` is relative to the
dire in which the skil lis installed.

##### shoppinglist=shoppinglist.json
Name of the shopping list file.

##### printer=LaserHome
Name of the printer for printing the list. The printer must be installed
on the system. Best way is to use CUPS as described here:
`https://www.howtogeek.com/169679/how-to-add-a-printer-to-your-raspberry-pi-or-other-linux-computer/`.
