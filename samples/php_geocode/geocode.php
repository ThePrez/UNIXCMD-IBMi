<?php
    $address = fgets(STDIN);
    $wsdl = 'http://geocoder.us/dist/eg/clients/GeoCoderPHP.wsdl';
    $client = new SoapClient($wsdl);
    $result = $client->geocode($address);
    echo $result[0]->lat . "\n";
    echo $result[0]->long . "\n";
?>