options(warn=1)
library("DESeq2")

files <- list.files(path="/mnt/projects/sarah/results/htseq/", pattern=".count$")

# remove samples from initial proof-of-principle project
names <- gsub("C4H29ACXX_([^_]+)_.*", "\\1", files, perl=T)
samples <- data.frame(name=names, file=files, stringsAsFactors=F)

# transform counts into normalized values
cds <- DESeqDataSetFromHTSeqCount(sampleTable=samples, directory="/mnt/projects/sarah/results/htseq", design=~1)

# regularized log transformation
rld <- rlog(cds)
rlogMat <- assay(rld)

# variance stabilizing transformation
#vsd <- varianceStabilizingTransformation(cds)
#vstMat <- assay(vsd)

# annotate genes with Ensembl biomart (mouse, not human!)
biomartfile <- "/mnt/projects/sarah/data/ensembl/genes.GRCm38.75.biomart.RData"
if(file.exists(biomartfile)) {
	load(biomartfile)
} else {
	library("biomaRt")
	mart <- useMart(biomart="ENSEMBL_MART_ENSEMBL", host="feb2014.archive.ensembl.org", dataset="mmusculus_gene_ensembl") # GRCm38, v75
	genes <- getBM(attributes=c("ensembl_gene_id", "mgi_symbol", "description", "chromosome_name", "band", "strand", "start_position", "end_position"), mart=mart)
	save(genes, file=biomartfile)
}

rlogMat.ann <- as.data.frame(rlogMat)
rlogMat.ann$ensembl_gene_id <- rownames(rlogMat)
rlogMat.ann <- merge(rlogMat.ann, genes, all.x=T)

# write table
ncols <- ncol(rlogMat.ann)
write.table(rlogMat.ann[,c(1, (ncols-6):ncols,2:(ncols-7))], file="/data/modicell/sarah/qlucore/deseq2-normalized-counts.tsv", col.names=T, row.names=F, sep="\t", quote=F)

