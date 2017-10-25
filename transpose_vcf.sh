#!/bin/awk -f

BEGIN{FS="\t"}
$1!~"##"{   
	if (NF > nf) {nf = NF}
	for (i=1; i<=6; i++){
		row[i] = row[i] $i "\t"
	}
	for (i=9; i<=nf; i++) {
		split($i,a,":")
		row[i-2] = row[i-2] a[1] "\t"
	}
}
END{
	for (i=1; i<=nf; i++) {
		printf("%s\n",row[i])
	}
}
