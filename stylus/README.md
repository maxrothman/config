# Applying patches

Because some of the custom styles in this directory are modifications of styles
available on [userstyles.org](https://userstyles.org/), those styles are stored as
patches rather than full files.

To install a style with a patch:
* Download the original style from [userstyles.org](https://userstyles.org/)
* using GNU patch, run:

      patch --verbose --merge <original-style> <patch-file>

  then resolve any conflicts manually.
* Copy-paste the patched style into a new custom style

To create a patch, take a modified style and run:

    diff <original-style> <modified-style> > <style-name>.patch

