#!/bin/awk -f
NR>1 && NF>1 {i7[NR-1]=$1;i5[NR-1]=$2}; NF==1 {i7[NR-1]=$1}
END{
c=1
printf("[Header]\nInvestigator Name,Xiushan Yin\nExperiment Name,CRISPR\nDate,06/09/2017\nWorkflow,GenerateFASTQ\nApplication,MiniSeq FASTQ Only\n\n[Reads]\n151\n151\n\n[Setting]\n")
printf("\n[Data]\nSample_ID,Sample_Name,I7_Index_ID,index,I5_Index_ID,index2,Sample_project\n")
for (i=1;i<=length(i7);i++){
	for (j=1;j<=length(i5);j++){
		printf("sample_%03d,sample_%03d,i7_%02d,%s,i5_%02d,%s,fastq\n",c,c,i,i7[i],j,i5[j])
		c++
		}
	}
}

