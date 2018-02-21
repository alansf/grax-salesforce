/// cpdjsofjalksdfjklasdf

public with sharing class Neo4jClient {

    private HttpRequest request;

    public Neo4jClient() {

        request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Basic YXBwODM0Mzg2Nzktb3lZcWVBOmIuOFNkQXQzQ01uRHpCLnBzeFdUQ0lheElaaVBORnc=');
        request.setEndpoint('https://hobby-ilpalckeehocgbkeoncdnjal.dbs.graphenedb.com:24780/db/data/cypher');

    }

    public HttpResponse query(String data) {

        request.setBody(data);
        return send();
    }

    private HttpResponse send() {

        System.debug(request.getBody());
        return (new Http()).send(request);
    }

}