mv /var/lib/jetty/webapps/ROOT.war /var/lib/jetty/webapps/plantuml.war
exec /docker-entrypoint.sh "$@"
