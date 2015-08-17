export SHELLOPTS:=errexit:pipefail
SHELL=/bin/bash  # required to make pipefail work
.SECONDARY:      # do not delete any intermediate files
LOG = perl -ne 'use POSIX qw(strftime); $$|=1; print strftime("%F %02H:%02M:%S ", localtime), $$ARGV[0], "$@: $$_";'

PROJECT_HOME=~/sarah
TRIM_BEFORE_BASE=1

BASELINE=C4H29ACXX_m1d0_14s005555-1-1_Heitger_lane114s005555_sequence \
	C4H29ACXX_m3d0_14s005562-1-1_Heitger_lane214s005562_sequence \
	C4H29ACXX_m5d0_14s005567-1-1_Heitger_lane314s005567_sequence \
	C4H29ACXX_m6d0_14s005574-1-1_Heitger_lane414s005574_sequence
OTHER=C4H29ACXX_BM4Exp23_14s005581-1-1_Heitger_lane514s005581_sequence \
	C4H29ACXX_CTLA4Ig1Exp23_14s005582-1-1_Heitger_lane514s005582_sequence \
	C4H29ACXX_CTLA4Ig2Exp23_14s005583-1-1_Heitger_lane514s005583_sequence \
	C4H29ACXX_m1d1aCD28_14s005558-1-1_Heitger_lane114s005558_sequence \
	C4H29ACXX_m1d1CTLA4Ig_14s005557-1-1_Heitger_lane114s005557_sequence \
	C4H29ACXX_m1d1wo_14s005556-1-1_Heitger_lane114s005556_sequence \
	C4H29ACXX_m1d3aCD28_14s005561-1-1_Heitger_lane214s005561_sequence \
	C4H29ACXX_m1d3CTLA4Ig_14s005560-1-1_Heitger_lane114s005560_sequence \
	C4H29ACXX_m1d3wo_14s005559-1-1_Heitger_lane114s005559_sequence \
	C4H29ACXX_m3d1CTLA4Ig_14s005564-1-1_Heitger_lane214s005564_sequence \
	C4H29ACXX_m3d1wo_14s005563-1-1_Heitger_lane214s005563_sequence \
	C4H29ACXX_m3d3CTLA4Ig_14s005566-1-1_Heitger_lane214s005566_sequence \
	C4H29ACXX_m3d3wo_14s005565-1-1_Heitger_lane214s005565_sequence \
	C4H29ACXX_m5d1aCD28_14s005570-1-1_Heitger_lane314s005570_sequence \
	C4H29ACXX_m5d1CTLA4Ig_14s005569-1-1_Heitger_lane314s005569_sequence \
	C4H29ACXX_m5d1wo_14s005568-1-1_Heitger_lane314s005568_sequence \
	C4H29ACXX_m5d3aCD28_14s005573-1-1_Heitger_lane414s005573_sequence \
	C4H29ACXX_m5d3CTLA4Ig_14s005572-1-1_Heitger_lane314s005572_sequence \
	C4H29ACXX_m5d3wo_14s005571-1-1_Heitger_lane314s005571_sequence \
	C4H29ACXX_m6d1aCD28_14s005577-1-1_Heitger_lane414s005577_sequence \
	C4H29ACXX_m6d1CTLA4Ig_14s005576-1-1_Heitger_lane414s005576_sequence \
	C4H29ACXX_m6d1wo_14s005575-1-1_Heitger_lane414s005575_sequence \
	C4H29ACXX_m6d3aCD28_14s005580-1-1_Heitger_lane514s005580_sequence \
	C4H29ACXX_m6d3CTLA4Ig_14s005579-1-1_Heitger_lane514s005579_sequence \
	C4H29ACXX_m6d3wo_14s005578-1-1_Heitger_lane414s005578_sequence \
	C4H29ACXX_woExp23_14s005584-1-1_Heitger_lane514s005584_sequence
SAMPLES=$(BASELINE) $(OTHER)

SPACE :=
SPACE +=
COMMA := ,

#all: gsnap htseq qc blast fastqc
all: /data/modicell/sarah/qlucore/deseq2-normalized-counts.tsv

#include ~/generic/scripts/rna-seq/default.mk

.PHONY: htseq
htseq: $(foreach S, $(SAMPLES), htseq/$S.count)
htseq/%.count: /data/modicell/sarah/qlucore/%.qlucore.bam /data/modicell/pub/Mus_musculus.GRCm38.75.gtf
	mkdir -p htseq
	~/tools/HTSeq-0.6.1/scripts/htseq-count -f bam -t exon -s no $< $(word 2, $^)  | grep -vP "^__" > $@.part
	mv $@.part $@
	
/data/modicell/sarah/qlucore/deseq2-normalized-counts.tsv: htseq ~/sarah/scripts/get-deseq2-transformed-counts.R
	Rscript ~/sarah/scripts/get-deseq2-transformed-counts.R
