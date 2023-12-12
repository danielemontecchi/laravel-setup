#!/bin/bash

# ----------------------------------------------------------------------------------
# Author: Daniele Montecchi
# Date of creation: 12 Dec 2023
# Version: 1.0.0
# Description: Wizard for configuring new or existing Laravel projects
# Tested on : Mac OSX
# ----------------------------------------------------------------------------------

####################
#####  FUNCTIONS
####################

ecol() {
    local text="$1"
    local color="${2:-white}"  # Default: white
    local style="${3:-normal}" # Default: normal

    # Define color codes
    local color_code=""
    case $color in
        white)  color_code="\033[37m" ;;
        green)  color_code="\033[32m" ;;
        blue)   color_code="\033[34m" ;;
        red)    color_code="\033[31m" ;;
        yellow) color_code="\033[33m" ;;
        *)      color_code="\033[37m" ;; # Default to white if color is not recognized
    esac

    # Define style
    local style_code=""
    case $style in
        bold)   style_code="\033[1m" ;;
        italic) style_code="\033[3m" ;;
        *)      style_code="" ;; # Normal style if style is not recognized
    esac

    # Print the text
    echo "${style_code}${color_code}${text}\033[0m"
}

choices() {
    local question="$1"
    local options=("${@:2}")
    local num_options=${#options[@]}

    # Print the question
    ecol " "
    ecol "$question" "green" "normal"

    # Print the options
    # shellcheck disable=SC2004
    for (( i=0; i<$num_options; i++ )); do
        local option_num=$((i+1))
        # shellcheck disable=SC2005
        echo "$(ecol "[$option_num]" "white" "normal") $(ecol "${options[$i]}" "blue" "normal")"
    done

    # Get user choice
    local choice
    ecol "Enter your choice (1-$num_options): "
    # shellcheck disable=SC2162
    read choice

    # Validate choice and default to the last option if invalid
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$num_options" ]; then
        choice="$num_options"
    fi

    return "$choice"
}

ask() {
    # Get user response
    local response
    # shellcheck disable=SC2162
    read response
    echo "$response"
}

confirm() {
    local response
    # shellcheck disable=SC2162
    read response
    response=${response:-y}  # Default value if no response is given

    # Convert response to lowercase
    response=$(echo "$response" | awk '{print tolower($0)}')

    # Check if response is 'y' or 'n'
    if [[ "$response" == "n" ]]; then
        # shellcheck disable=SC2152
        echo "n"
    else
        # shellcheck disable=SC2152
        echo "y"
    fi
}

download() {
  local local_path="$1"
  local remote_path="$2"

  local base_url="https://raw.githubusercontent.com/danielemontecchi/laravel-setup/master"
  local full_url="${base_url}/${remote_path}"

  curl -s -o "${local_path}" "${full_url}"
}


####################
#####  SETUP
####################

ecol " "
ecol ">>> ATTENTION <<<" "red" "bold"
ecol "----------------------------------------------------------------------------------" "red"
ecol "This script creates and configures new Laravel projects." "red"
ecol "It can also be run as a simple configurator of existing designs." "red"
ecol "Run this script in the main projects folder on your computer." "red"
ecol "----------------------------------------------------------------------------------" "red"
ecol "Have a nice code <3" "yellow" "bold"
ecol " "

choices "What engine do you use on your system?" \
             "Laravel Valet" \
             "Laravel Sail" \
             "Standard PHP and Composer" \
             "Define it"
engines=$?
case $engines in
1)
	engine_composer="valet composer"
	engine_php="valet php"
	;;
2)
	engine_composer="sail composer"
	engine_php="sail php"
	;;
3)
	engine_composer="composer"
	engine_php="php"
	;;
*)
	ecol "Enter the full command you use to use COMPOSER (ex: sail composer):" "green"
	engine_composer=$(ask)
	if [ -z "$engine_composer" ]; then
		ecol "!!!WARNING!!! The engine cannot be empty." "red" "bold"
		exit
	else
    # Check the correct execution of the engines
    if ! command -v "$engine_composer" >/dev/null; then
      ecol "!!!WARNING!!! COMPOSER engine cannot be started." "red" "bold"
      exit
    fi
	fi

	ecol "Enter the full command you use to use PHP (ex: sail php):" "green"
	engine_php=$(ask)
	if [ -z "$engine_php" ]; then
		ecol "!!!WARNING!!! The engine cannot be empty." "red" "bold"
		exit
	else
    # Check the correct execution of the engines
    if ! command -v "$engine_php" > /dev/null; then
      ecol "!!!WARNING!!! PHP engine cannot be started." "red" "bold"
      exit
    fi
	fi
	;;
esac


####################
#####  PROJECT CREATION
####################

# Ask the user to enter the name of the project folder
ecol ""
ecol "Enter the name of the project folder:" "green"
folder_name=$(ask)
if [ -z "$folder_name" ]; then
	ecol "!!!WARNING!!! The project name cannot be blank." "red" "bold"
	exit
fi
script_dir=$(pwd)

# If the folder does not exist I consider it a new project
if [ ! -d "$script_dir/$folder_name" ]; then
	new_project="true"
	ecol "creating the project $folder_name ..." "" "italic"
	if command -v laravel >/dev/null; then
	  laravel new "$folder_name" > /dev/null 2>&1
	else
	  $engine_composer create-project laravel/laravel example-app
	fi
	# shellcheck disable=SC2164
	cd "$folder_name"
	echo "# $folder_name" > README.md
	env_base="y"
	if [ "$engines" == "1" ]; then
	  # With Valet I force the PHP version to the one indicated
	  echo "php=php@$PHP_VERSION" > .valetrc
	fi
else
  # shellcheck disable=SC2164
  cd "$folder_name"
	new_project="false"
	if [ -f "./.env" ]; then
		ecol "You want to set the basic variables? [Y/n]" "green"
		env_base=$(confirm)
	else
		env_base="n"
	fi
fi
# gitignore
rm .gitignore
download "./.gitignore" "laravel/gitignore"
if [ "$env_base" == "y" ]; then
	# I change the base values of the.env.example
	sed -i '' "s/^APP_NAME=.*/APP_NAME=\"$folder_name\"/" "./.env.example"
	sed -i '' "s/^LOG_CHANNEL=.*/LOG_CHANNEL=daily/" "./.env.example"
	sed -i '' "s/^CACHE_DRIVER=.*/CACHE_DRIVER=redis/" "./.env.example"
	sed -i '' "s/^SESSION_DRIVER=.*/SESSION_DRIVER=redis/" "./.env.example"
	# I change the base values of the.env
	sed -i '' "s/^APP_NAME=.*/APP_NAME=\"$folder_name\"/" "./.env"
	sed -i '' "s/^LOG_CHANNEL=.*/LOG_CHANNEL=daily/" "./.env"
	sed -i '' "s/^CACHE_DRIVER=.*/CACHE_DRIVER=redis/" "./.env"
	sed -i '' "s/^SESSION_DRIVER=.*/SESSION_DRIVER=redis/" "./.env"
	sed -i '' "s/^MAIL_HOST=.*/MAIL_HOST=127.0.0.1/" "./.env"
	sed -i '' "s/^MAIL_PORT=.*/MAIL_PORT=2525/" "./.env"
	sed -i '' "s/^MAIL_USERNAME=.*/MAIL_USERNAME=\"\$\{APP_NAME\}\"/" "./.env"
	# I change the values of the config
	sed -i '' "s/'locale' => 'en'/'locale' => 'it'/g" "./config/app.php"
	sed -i '' "s/'timezone' => 'UTC'/'timezone' => 'Europe\/Rome'/g" "./config/app.php"
	# Substitution of classes
	download "./app/Providers/AppServiceProvider.php" "laravel/Providers/AppServiceProvider.php"
	download "./app/Providers/DatabaseServiceProvider.php" "laravel/Providers/DatabaseServiceProvider.php"
	download "./app/Providers/ResponseServiceProvider.php" "laravel/Providers/ResponseServiceProvider.php"
	download "./app/Providers/ViewServiceProvider.php" "laravel/Providers/ViewServiceProvider.php"
	# linux: sed -i '' "/App\\\\Providers\\\\AuthServiceProvider::class,/a        App\\\\Providers\\\\DatabaseServiceProvider::class," ./config/app.php
	sed -i '' "/App\\\\Providers\\\\AuthServiceProvider::class,/a\\
        App\\\\Providers\\\\DatabaseServiceProvider::class,\\
        App\\\\Providers\\\\ResponseServiceProvider::class,\\
        App\\\\Providers\\\\ViewServiceProvider::class,\\
" ./config/app.php
fi


####################
#####  PACKAGE INSTALLATION
####################

echo ""
ecol "Do you want to install the necessary composer packages? [Y/n]" "green"
answer=$(confirm)
if [ "$answer" == "y" ]; then
	ecol "installing the necessary packages ..." "" "italic"
	$engine_composer update > /dev/null 2>&1
	# Install DebugBar
	$engine_composer require barryvdh/laravel-debugbar --dev > /dev/null 2>&1
	$engine_php artisan vendor:publish --provider="Barryvdh\Debugbar\ServiceProvider" > /dev/null 2>&1
	if [ -f "./config/debugbar.php" ]; then
	  sed -i '' "s/'enabled' => env('DEBUGBAR_ENABLED', null),/'enabled' => env('DEBUGBAR_ENABLED', env('APP_DEBUG', null)),/g" "./config/debugbar.php"
	fi
	# Install LogViewer
	$engine_composer require opcodesio/log-viewer > /dev/null 2>&1
	$engine_php artisan vendor:publish --tag="log-viewer-config" > /dev/null 2>&1
	if [ -f "./config/log-viewer.php" ]; then
	  sed -i '' "s/log-viewer/logs/g" "./config/log-viewer.php"
	fi
	# Install Makes
	$engine_composer require digitalion/laravel-makes --dev > /dev/null 2>&1
	# Install other packages
	$engine_composer require barryvdh/laravel-ide-helper --dev > /dev/null 2>&1
	$engine_composer require spatie/laravel-backup > /dev/null 2>&1
	$engine_composer require spatie/laravel-ray --dev > /dev/null 2>&1
	$engine_php artisan ray:publish-config > /dev/null 2>&1
	$engine_composer require enlightn/laravel-security-checker --dev > /dev/null 2>&1
	# Configure Redis
	$engine_composer require predis/predis > /dev/null 2>&1
	if [ -f "./config/database.php" ]; then
	  sed -i '' "s/phpredis/predis/g" "./config/database.php"
	fi
fi


####################
#####  STARTER KIT
####################

# Select Starter Kits
choices "Do you want to install one of the Laravel Starter Kits?" \
                      "Laravel Breeze" \
                      "Laravel JetStream" \
                      "Laravel JetStream (with support at Teams)" \
                      "Filament Admin Panel" \
                      "None"
starter_kit=$?
admin_mail=""
case $starter_kit in
1)
  ecol "configuring Laravel Breeze ..." "" "italic"
	$engine_composer require laravel/breeze --dev > /dev/null 2>&1
	$engine_php artisan breeze:install
	;;
2)
  ecol "configuring Laravel JetStream ..." "" "italic"
	$engine_composer require laravel/jetstream > /dev/null 2>&1
	$engine_php artisan jetstream:install livewire > /dev/null 2>&1
	;;
3)
  ecol "configuring Laravel JetStream with Teams ..." "" "italic"
	$engine_composer require laravel/jetstream > /dev/null 2>&1
	$engine_php artisan jetstream:install livewire --teams > /dev/null 2>&1
	;;
4)
  ecol "configuring Filament Admin Panel ..." "" "italic"
  $engine_php artisan migrate --force > /dev/null 2>&1
	$engine_composer require filament/filament:"^3.1" -W > /dev/null 2>&1
	$engine_php artisan filament:install --panels -n > /dev/null 2>&1
	$engine_php artisan vendor:publish --tag=filament-config > /dev/null 2>&1
esac


####################
#####  FORMATTER
####################

ecol ""
ecol "Do you want to install the PHP CS Fixer formatter? [Y/n]" "green"
answer=$(confirm)
if [ "$answer" == "y" ]; then
	ecol "configuring PHP CS Fixer ..." "" "italic"
	$engine_composer require --dev friendsofphp/php-cs-fixer:* > /dev/null 2>&1
	# php cs fixer
	download ".php-cs-fixer.php" "php-cs-fixer/config.php"
	# git
	download ".git/hooks/pre-commit" "git/pre-commit"
	# vs code
	download ".editorconfig" "vscode/editorconfig"
	# shellcheck disable=SC2006
	# shellcheck disable=SC2012
	# shellcheck disable=SC2035
	count=`ls -1 *.code-workspace 2>/dev/null | wc -l`
	if [ "$count" == "0" ]
	then
		CURRENT_DIR=${PWD##*/}
		download "${CURRENT_DIR}.code-workspace" "vscode/base.code-workspace"
	fi
	# format
	sh .git/hooks/pre-commit > /dev/null 2>&1
fi


####################
#####  FINALIZATION
####################

ecol " "
ecol "finalizing the wizard ..." "" "italic"
ecol " "
# I fill in the whole
npm install > /dev/null 2>&1
npm run build > /dev/null 2>&1
$engine_php artisan migrate --force > /dev/null 2>&1
# Initialize git
git init > /dev/null 2>&1
git add . > /dev/null 2>&1
if [ "$new_project" == "true" ]; then
	git commit -m "Installed Laravel and configured the project with basic settings" > /dev/null 2>&1
	ecol "Project successfully installed and configured" "green" "bold"
else
	git commit -m "Configured the project with basic settings" > /dev/null 2>&1
	ecol "Project successfully configured" "green" "bold"
fi

# Start the project with the referenced IDE
if command -v phpstorm >/dev/null 2>&1; then
  ( nohup phpstorm . > /dev/null 2>&1 & )
else
  first_file=$(find "./" -maxdepth 1 -type f -name "*.code-workspace" | head -n 1)
  if [ -n "$first_file" ]; then
    code "$first_file"
  fi
fi

# I start the browser at the project url
app_url=$(grep '^APP_URL=' "./.env" | cut -d '=' -f2-)
# Remove any quotation marks
app_url="${app_url%\"}"
app_url="${app_url#\"}"
# Check if URL is empty
# shellcheck disable=SC2236
if [ ! -z "$app_url" ]; then
	# Determine the operating system and open the URL in the default browser
	case "$(uname)" in
		"Linux")
			xdg-open "$app_url"
			;;
		"Darwin")
			open "$app_url"
			;;
		"MINGW"*|"MSYS"*|"CYGWIN"*)
			start "$app_url"
			;;
	esac
fi

# Determine the operating system and open the URL in the default browser
if [ "$starter_kit" == "4" ]; then
  admin_mail="$app_url"
  # shellcheck disable=SC2236
  if [ ! -z "$admin_mail" ]; then
    admin_mail="${admin_mail/http:\/\//}"
    admin_mail="${admin_mail/https:\/\//}"
  else
    admin_mail="admin@example.test"
  fi
	$engine_php artisan make:filament-user -n --name="Admin" --email="$admin_mail" --password="admin" > /dev/null 2>&1

  ecol " "
  ecol "-------------------------------------" "yellow"
  ecol ">>> PANEL ADMIN <<<" "yellow" "bold"
  ecol "url: $app_url/admin" "yellow"
  ecol "username: $admin_mail" "yellow"
  ecol "password: admin" "yellow"
  ecol "-------------------------------------" "yellow"
  ecol " "
fi

# shellcheck disable=SC2164
cd "$script_dir/$folder_name"
