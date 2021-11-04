#! /bin/bash

# permanip = permission + manipulation
# A utility tool for manipulating permission for files interactively

IFS=$'\n'
ch_entity=""
perm=""
chosen_file=""
# Function to print files in current directory
listing=""
print_files_in_pwd () {
	listing=$(ls -la $PWD)
}

# Get files
files=""
get_files () {
	for file in ./*
	do
		file_name="\""`basename "${file}"`"\""
		#files+=" `printf "%b" "$file_name"` "
		files+=" $(echo `basename "${file}"` | sed 's/ /\\ /g')"
		#basename "${file}"
		files+="\"`stat -c "%A" "${file}"`\""
	done
}

# Function to modify permissions

mod_perm () {
	declare -a args2=(
        --title "Choose the permission to modify"
        --menu "Use arrow keys to navigate" 25 78 16 --
        )

	en_rd="Enable read"
	en_wr="Enable write"
	en_exe="Enable execute"

	dis_rd="Disable read"
	dis_wr="Disable write"
	dis_exe="Disable execute"

	octal_dgt=$1

	case $1 in
		4)
			args2+=("$dis_rd" "")
			args2+=("$en_wr" "Revoke read permission")
			args2+=("$en_exe" "Revoke read permission")
			;;
		2)
			args2+=("$en_rd" "Revoke read permission")
			args2+=("$dis_wr" "Revoke read permission")
			args2+=("$en_exe" "Revoke read permission")
			;;
		1)
			args2+=("$en_rd" "Revoke read permission")
                        args2+=("$en_wr" "Revoke read permission")
                        args2+=("$dis_exe" "Revoke read permission")
			;;
		6)
			args2+=("$dis_rd" "Revoke read permission")
                        args2+=("$dis_wr" "Revoke read permission")
                        args2+=("$en_exe" "Revoke read permission")
			;;
		3)
			args2+=("$en_rd" "Revoke read permission")
                        args2+=("$dis_wr" "Revoke read permission")
                        args2+=("$dis_exe" "Revoke read permission")
			;;
		5)
			args2+=("$dis_rd" "Revoke read permission")
                        args2+=("$en_wr" "Revoke read permission")
                        args2+=("$dis_exe" "Revoke read permission")
			;;
		7)
                        args2+=("$dis_rd" "Revoke read permission")
                        args2+=("$dis_wr" "Revoke read permission")
                        args2+=("$dis_exe" "Revoke read permission")
                        ;;
		0)
                        args2+=("$en_rd" "Revoke read permission")
                        args2+=("$en_wr" "Revoke read permission")
                        args2+=("$en_exe" "Revoke read permission")
                        ;;


	esac

	choice2=$(whiptail "${args2[@]}" 3>&1 1>&2 2>&3)
	case $choice2 in
		"$en_rd")
			((octal_dgt+=4))
			;;
		"$en_wr")
			((octal_dgt+=2))
			;;
		"$en_exe")
			((octal_dgt+=1))
			;;
		"$dis_rd")
			((octal_dgt-=4))
			;;
		"$dis_wr")
			((octal_dgt-=2))
			;;
		"$dis_exe")
			((octal_dgt-=1))
			;;
	esac

	octal_code=""
	case $3 in
                owner)
                        octal_code="${octal_dgt}${2:1:2}"
                        ;;
                group)
                        octal_code="${2:0:1}${octal_dgt}${2:2:1}" 
                        ;;
                other)
                        octal_code="${2:0:2}${octal_dgt}" 
                        ;;
	esac

	#echo "$2 => $octal_code"

	# Change the permissions
	sudo chmod "$octal_code" "$chosen_file"

	if(whiptail --yesno --title "Want to continue?" --scrolltext  "`ls -la $PWD`" 20 80 3>&1 1>&2 2>&3)
        then
		file_chooser
        else
                echo "Exiting..."
      	fi
		
}
# Function to generate and show available permission choices
gen_perm_choices () {
	perm=`stat -c "%a" $1`
	ch_entity=$(whiptail --title "Choose entity" --menu "Change permissions for:" 25 78 16 \
	"owner" "The one who owns the file" \
	"group" "The group to which this files is assigned to" \
	"other" "Every Tom, Dick and Harry" 3>&1 1>&2 2>&3)

	case $ch_entity in
		owner)
			mod_perm "${perm:0:1}" "$perm" "$ch_entity"
			;;
		group)
			mod_perm "${perm:1:1}" "$perm" "$ch_entity"
			;;
		other)
			mod_perm "${perm:2:1}" "$perm" "$ch_entity"
			;;
	esac
}

# Function file chooser
file_chooser () {
	declare -a args=(
	--title "Choose the file" 
	--menu "Use arrow keys to navigate" 25 78 16 --
	)
	for file in ./* 
	do
   		 args+=("`basename ${file}`" "`stat -c "%A" "${file}"`")
	done
	chosen_file=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3)
	gen_perm_choices "$chosen_file"
}

# Function to get the permission changes required
get_consent () {
	if(whiptail --yesno --title "Do you want to modify file permissions?" --scrolltext  "`ls -la $PWD`" 20 80 3>&1 1>&2 2>&3)
	then
		file_chooser
	else
		echo "Exiting..."
	fi	
}

print_files_in_pwd
get_consent







