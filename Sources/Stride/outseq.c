#include "stride.h"

int OutSeq(CHAIN **Chain, int NChain, COMMAND *Cmd) /*int OutSeqError)*/
{
  int Cn, Res; /*OutSeqError=0;*/
  FILE *Seq;

  if( (int)strlen(Cmd->SeqFile) == 0 )
    Seq = stdout;
  else 
    if( (Seq = fopen(Cmd->SeqFile,"a")) == NULL )
      die("Error writing sequence file %s\n",Cmd->SeqFile);
      /*OutSeqError=1;*/

  for( Cn=0; Cn<NChain; Cn++ ) {

    if( !Chain[Cn]->Valid )
       continue;

    fprintf(Seq,">%s %c  %d %7.3f\n",
	    Chain[Cn]->File,SpaceToDash(Chain[Cn]->Id),Chain[Cn]->NRes,
	    Chain[Cn]->Resolution);

    for( Res=0; Res<Chain[Cn]->NRes; Res++ ) {
      if( Res%60 == 0 && Res != 0 ) fprintf(Seq,"\n");
      fprintf(Seq,"%c",ThreeToOne(Chain[Cn]->Rsd[Res]->ResType));
    }
    fprintf(Seq,"\n");
  }
  fclose(Seq);
  exit(0);

  return(SUCCESS);
}

      

