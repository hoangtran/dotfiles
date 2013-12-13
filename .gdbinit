set output-radix 16

define add-module
        shell ~/bin/add-symbol-file.sh $arg0
        source ~/.gdb/add-symbol-file.gdb
end
document add-module
        Usage: add-module <module>

        Do add-symbol-file for module <module> automatically.
        Note: A map file with the extension ".map" must have
        been created with "insmod -m <module> > <module>.map"
        in advance.
end
