/^\[.*\]$/ {
    section = toupper($1) "__"
    gsub(/(\[|\])/, "", section)
    gsub(/\./,"_", section)
}

/^[a-zA-Z_]+ =/ {
    key_var = "GOGS_" section $1
    printf "%s = ${%s}\n", $1, key_var > "app.ini.template"

    # cut out var assignment
    $1="";$2="";sub(FS,"");sub(FS,"")

    printf "%s=\"${%s-%s}\"\n", key_var, key_var, $0 > "app.ini.vendor-defaults"
    next
}

{ print > "app.ini.template"}
