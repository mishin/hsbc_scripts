

cd job.hub

for i in [A-G]*.dsx ; do
  cat $i |awk '/^BEGIN DSJOB/,/^END DSJOB/{print}' >>../ag.dsx
done

for i in H*.dsx ; do
  cat $i |awk '/^BEGIN DSJOB/,/^END DSJOB/{print}' >>../h.dsx
done

for i in [I-R]*.dsx ; do
  cat $i |awk '/^BEGIN DSJOB/,/^END DSJOB/{print}' >>../ir.dsx
done

for i in [S-Z]*.dsx ; do
  cat $i |awk '/^BEGIN DSJOB/,/^END DSJOB/{print}' >>../sz.dsx
done

cd job.tts

for i in [A-I]*.dsx ; do
  cat $i |awk '/^BEGIN DSJOB/,/^END DSJOB/{print}' >>../ai.dsx
done

for i in [J-Z]*.dsx ; do
  cat $i |awk '/^BEGIN DSJOB/,/^END DSJOB/{print}' >>../jz.dsx
done




