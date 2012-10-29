#!/bin/bash

# Set the "field separator" to something other than spaces/newlines" so that spaces
# in the file names don't mess things up. I'm using the pipe symbol ("|") as it is very
# unlikely to appear in a file name.
IFS="|"

# The script should be invoked as "pdf2cbz {directory}", where "{directory}" is the
# top-level directory to be searched. Just to be paranoid, if no directory is specified,
# then default to the current working directory ("."). Let's put the name of the
# directory into a shell variable called WORKDIR.
# Note: "$1" = "The first command line argument"
if test -z $1; then
    WORKDIR="."
else
    WORKDIR="$1"
fi
echo "Working from directory $WORKDIR"

# Now, execute a loop, based on a "find" command in the specified directory. The
# "-printf "$p|" will cause the file names to be separated by the pipe symbol, rather than
# the default newline. Note the backtics ("`") (the key above the tab key on US
# keyboards).
for pdfFILE in `find $WORKDIR -name "*.pdf" -printf "%p|"`; do
    # Now for the actual work. First, extract the base file name (without the extension)
    # using the "basename" command. Warning: more backtics.
    BASENAME=`basename $pdfFILE ".pdf"`

    # And the directory path for that file, so we know where to put the finished ".cbz"
    # file. You could potentially hard code this to a single directory - your choice...
    # backtics again...
    DIRNAME=`dirname $pdfFILE`

    # For the new file name, let's convert any spaces to underscores. We'll do this with
    # a "sed" (stream editor) command. Backtics again.
    NEWBASEFILE=`echo "$BASENAME" | sed "s/ /_/g"`

    # Now, build the "new" file name,
    NEWNAME="$NEWBASEFILE.cbz"

    # We need a guaranteed empty directory to work in, so I'm creating a temp
    # directory under the current working directory. It will be deleted when we're
    # done with it:
    mkdir pdf2cbztemp
    cd pdf2cbztemp

    # Now that the preliminaries are done, we start doing some work.
    # We need to copy the ".pdf" into the current "temp" directory for
    # unpacking/repacking.
    cp "$pdfFILE" .

    # rename the file to a ".rar" file. I don't think this is necessary, but it shouldn't
    # cause any problems...
    echo "Converting file: $BASENAME.pdf to svg..."
    pdf2svg "$BASENAME.pdf" page%03d.svg all
    
    echo "Converting svg to png..."
    for i in *; do rsvg-convert $i -o `echo $i | sed -e 's/svg$/png/'`; done
    # Create the ".cbz" file
    echo "Zipping..."
    zip "$NEWNAME" *.png

    # And move it to the directory where we found the original ".pdf" file
    cp "$NEWNAME" "$DIRNAME"

    # Finally, "cd" back to the original working directory, and delete the temp directory
    # created earlier.
    cd ..
    rm -r pdf2cbztemp
    echo "FINISHED converting $BASENAME.pdf"

    # At this point, you could potentially 'rm "$pdfFILE"' to delete the original, but
    # I'd suggest not doing so until you're certain you've got a good ".cbz" file...

done



