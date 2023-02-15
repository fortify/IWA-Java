Del *.fpr
del *.log
mvn clean package
sourceanalyzer -b iwa -clean
sourceanalyzer -b iwa -cp "**/*" "**/*" -source 11 -sql-language PL/SQL -debug -logfile trans.log -verbose
sourceanalyzer -b iwa -debug -logfile scan.log -scan -f iwa.fpr -Dcom.fortify.sca.rules.enable_wi_correlation
start "" "iwa.fpr"
