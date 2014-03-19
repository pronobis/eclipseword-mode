eclipseword-mode
================

An Emacs minor mode for handling words (almost) like Eclipse does.

This mode considers the following in its word definition:
- camel case e.g.
  ```
  these|Are|Different|Words
  ```

- multiple upper-case characters e.g.
  ```
  THESE|are|DIFFERENT|words
  ```

- numbers e.g.
  ```  
   these|Are|33|WORDS
  ```

- symbols e.g. 
  ```
  these|((|are|))|words
  ```

- single white space (different when moving forward and backward) e.g. 
  ```
  these| are| words| forward
  ```
  and 
  ``` 
  these |are |words |backward
  ```

- single underscore characters (different when moving forward and backward) e.g. 
  ```
  these|_are|_words|_forward
  ``` 
  and
  ```
  these_|are_|words_|backward
  ```

- multiple white spaces 
  ```
  these|     |are|     |words
  ```

- end and beginning of a line
  ```
  |      |these|
  |are|        |
  |    |words|
  ```


Usage
-----

First, make it available in Emacs by adding the following lines to your .emacs file:
```
(add-to-list 'load-path "<path_to_the_eclipseword.el_file>")
(require 'eclipseword)
```
Of course, don't forget to **change the path**!

To make the mode turn on automatically, put the following code in your .emacs:
```
(add-hook 'c-mode-common-hook
    (lambda () (eclipseword-mode 1)))
```

Or instead add:
```
(global-eclipseword-mode 1)
```
to automatically enable the mode for all buffers.
