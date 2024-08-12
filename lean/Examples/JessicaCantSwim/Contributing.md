# Contributing Guidelines

This is the contributing guidelines for Jessica Can't Swim.

## Monads

They are great, but they make it harder for others to understand.

Limit monads to:

* `IO Unit` for render functions.
* `Id <yourtypehere>` for imperative code.

## namespaces and imports

* Every file should start with and end a namespace
* namespaces are not separated by dots, they are single words.
* Do not use `open`, only used qualified imports.
