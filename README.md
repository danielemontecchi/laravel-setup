![](./assets/icon.png)

# Laravel Projects
_Wizard for configuring new or existing Laravel projects_

> :warning: **WARNING** :warning:
> 
> For the time being, this script has only been successfully tested on a Mac OSX system.
> 
> If you want to contribute to the improvement of this wizard on other operating systems, you know what to do ;)

# Installation

As a configurator, a shell file was made to be run at the command line directly **in the folder of the project to be configured**.
At startup, the command will run an installation wizard, asking the user to confirm each command.

1) download the script:
`curl -s -o setup.sh https://raw.githubusercontent.com/danielemontecchi/laravel-setup/master/setup.sh`
2) sets permissions for execution: `chmod +x setup.sh`
3) run script: `sh ./temp_script.sh`

## Customization

To customize the script and project files with your own needs, fork or clone this repository and change it as you like.

# PHP CS Fixer

## Visual Studio Code
PHP CS Fixer you can also install it as the default formatter for PHP on Visual Studio Code.

To do this you need to follow a few steps:

### 1. Extension
The extension is used precisely to allow VS Code to perform formatting each time files are saved.

To install it, visit its page in the [VS Code marketplace](https://marketplace.visualstudio.com/items?itemName=junstyle.php-cs-fixer).

### 2. Installation
To properly configure PHP CS Fixer, you need to install it globally on your system.

To do so, follow the [official guide](https://github.com/PHP-CS-Fixer/PHP-CS-Fixer/blob/master/doc/installation.rst#installation-1) where different methods are defined depending on your OS.

### 3. Configuration
The configuration guide for VS Code can be found in the following [README](https://github.com/junstyle/vscode-php-cs-fixer/blob/master/README.md#php-cs-fixer-for-visual-studio-code).

Once completed, when saving any PHP file, you should get a file formatted according to the rules, with no errors from VS Code.

## PHP Storm

To install and configure the formatter PHP CS Fixer, follow the instructions on the [JetBrains help portal](https://www.jetbrains.com/help/phpstorm/using-php-cs-fixer.html#installing-configuring-php-cs-fixer).

# EditorConfig for VS Code

This is another extension useful for formatting files, even non-PHP files.
You can install it directly from its page in the [VS Code marketplace](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig).