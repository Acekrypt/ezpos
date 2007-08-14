
require 'mkmf'

if have_library("lptxn", "") && have_library("lpssl", "")
    create_makefile("charge")
    `perl -pi -e "s/gcc/g\+\+/g" Makefile`
else
     puts "Could not find lptxn and/or lpssl libraries: Makefile not created" 
end



