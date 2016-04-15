<?php

// test_wtc_api.php
// 20160410/PPM Created

// Warning: This scripts doesn't work without valid credentials in wtc_parameters


test_wtc_api();


// test_wtc_api()
// Description: Send request, show result



function xml_entities($string) {
    return strtr(
        $string, 
        array(
            "<" => "&lt;",
            ">" => "&gt;",
            '"' => "&quot;",
            "'" => "&apos;",
            "&" => "&amp;",
        )
    );
}

function convertdate_last2to($date_last){
	$date_to = date('Y-m-d', strtotime($date_last.' + 1 day'));

	return $date_to;
}


function test_wtc_api(){

	// Initialize
	$fname = __FUNCTION__;
	$dbg = 1;

	if($dbg>0){ echo "$fname()<br>\n"; }

	// WtC parameters
	$wtc_client_code = 'CLIENT_TICKETCOUNTER_API';
	$wtc_case_code = 'TCAPI_CLIENT_NAME';
	$wtc_client_username = 'username_api';
	$wtc_client_password = 'rand0mpa55w0rd';
	$wtc_request_url = 'https://ticketing.wheretocard.nl/ticketService/submitOrder';

/*
CLIENT_TICKETCOUNTER_API
Case:
TCAPI_CLIENT_NAME
Apicodes:
TICKET_KIND_1_API_CODE
TICKET_KIND_2_API_CODE
*/

	// Construct name
	$order_code = '1234';
	$name = 'My Name';
	$email = 'myemail@myemail.com';
	$street = 'My Street';
	$house_number = 123;
	$postal_code = '1234AB';	
	$city = 'My City';	

	// To xml
	$xml_order_code = xml_entities($order_code);
	$xml_name = xml_entities($name);
	$xml_email = xml_entities($email);
	$xml_street = xml_entities($street);
	$xml_house_number = xml_entities($house_number);
	$xml_postal_code = xml_entities($postal_code);
	$xml_city = xml_entities($city);

	$properties_first_name = '';
	$properties_infix = '';
	$properties_last_name = $xml_name;
	$properties_email = $xml_email;
	$properties_street = $xml_street;
	$properties_house_number = $xml_house_number;
	$properties_postal_code = $xml_postal_code;
	$properties_city = $xml_city;

	if($dbg>0){ echo "$fname: prepare xml request ...<br>\n"; }

	// Construct orderlines by constructing orderline items
	// <orderline code="{{ reservation.producttypeperiodtime.producttypeperiod.producttype.code }}" ticket-ref="{{ reservation.number }}"><quantity>1</quantity><price>{{ reservation.price|makeCents }}</price><action>{{ reservation.producttypeperiodtime.producttypeperiod.producttype.name }}</action><validPeriod from="{{ reservation.reservationdate|date:"Y-m-d" }}T00:00:00" to="{{ reservation.reservationdate|addDays:1|date:"Y-m-d" }}T00:00:00"/></orderline>
	
	$orderitems = array();
	// Product#1
	$orderitems[] = array( 
	'product_code'		=> 'TICKET_KIND_1_API_CODE',
	'product_name'		=> 'My Ticket',
	'quantity'			=> 1, 
	'unitprice'			=> 1150,
	'dated_from'		=> '2016-04-10',	
	'dated_last'		=> '2016-06-30',	
	);
	// Product#2
	$orderitems[] = array(
	'product_code'		=> 'TICKET_KIND_2_API_CODE',
	'product_name'		=> 'My Ticket 2',
	'quantity'			=> 2, 
	'unitprice'			=> 2250,
	'dated_from'		=> '2016-04-10',	
	'dated_last'		=> '2016-06-30',	
	
	);
	
	$orderlines = array();
	foreach($orderitems as $orderitem){

		$xml_orderline_ticketref = 23;

		$xml_orderline_code = $orderitem['product_code'];

		$xml_quantity = $orderitem['quantity'];
		$orderline_quantity =<<<EOT
<quantity>$xml_quantity</quantity>
EOT;

		$xml_price = $orderitem['unitprice'];
		$orderline_price =<<<EOT
<price>$xml_price</price>
EOT;

		$validPeriod_from = $orderitem['dated_from'].'T00:00:00';
		$validPeriod_to = convertdate_last2to($orderitem['dated_from']).'T00:00:00';
		$orderline_validPeriod =<<<EOT
<validPeriod from="$validPeriod_from" to="$validPeriod_to"/>
EOT;

		$xml_product_name = xml_entities($orderitem['product_name']);
		$orderline_action =<<<EOT
<action>$xml_product_name</action>
EOT;

		// Construct orderline
		$orderline = '<orderline code="'.$xml_orderline_code.'" ticket-ref="'.$xml_orderline_ticketref.'">'.$orderline_quantity.$orderline_price.$orderline_action.$orderline_validPeriod.'</orderline>';

		// Add to list
		$orderlines[] = $orderline;
	}

	// Join orderlines
	$orderlines_list = join("\n", $orderlines);

	$xml_request_data = <<<EOT
<orderRequest version="1.0">
	<client code="$wtc_client_code">
		<username>$wtc_client_username</username>
		<password>$wtc_client_password</password>
	</client>
	<order referenceId="$xml_order_code">
		<properties>
			<property name="FIRST_NAME" value="$properties_first_name"/>
			<property name="INFIX" value="$properties_infix"/>
			<property name="LAST_NAME" value="$properties_last_name"/>
			<property name="EMAIL" value="$properties_email"/>
			<property name="STREET" value="$properties_street"/>
			<property name="HOUSE_NUMBER" value="$properties_house_number"/>
			<property name="POSTAL_CODE" value="$properties_postal_code"/>
			<property name="CITY" value="$properties_city"/>
		</properties>
		<cases>
			<case code="$wtc_case_code">
				<orderlines>
$orderlines_list
				</orderlines>
			</case>
		</cases>
	</order>
	<tickets>
	<ticket ref="23" delivery-channel="WEB" delivery-format="BARCODE">
	</ticket>
	</tickets>
</orderRequest>
EOT;

	if($dbg>0){ echo "$fname: wtc_request_url = ".$wtc_request_url."<br>\n"; }
	if($dbg>0){ echo "$fname: xml_request_data = ".$xml_request_data; }


	$ch = curl_init();
	curl_setopt($ch, CURLOPT_HTTPHEADER, array('Expect:', 'Content-Type: text/xml')); 
	curl_setopt($ch, CURLOPT_URL, $wtc_request_url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_POST, 1);
	curl_setopt($ch, CURLOPT_TIMEOUT, 30);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $xml_request_data);

	$time_start = time();
	$result = curl_exec($ch);
	$time_end = time();

	if($dbg>0){ echo "$fname: result = ".$result; }

	$time_diff = $time_end - $time_start;
	if($dbg>0){ echo "$fname: curl request executed in $time_diff second(s)<br>\n"; }

	$curl_errors = 0;
	$curl_errors_msg = '';
	if(curl_errno($ch)){
		// print curl_error($ch);
		$curl_errors++;
		$curl_errors_msg = curl_error($ch);
		if($dbg>0){ echo "$fname: curl_error = ".$curl_errors_msg."<br>\n"; }
		$result = '';
	}else{
		if($dbg>0){ echo "$fname: NO curl error(s)<br>\n"; }
	}
	curl_close($ch);

	$got_ok = 0;
	$got_url = 0;
	$url = '';
	if($curl_errors == 0){
		// Try to locate OK (= <orderResponse status="OK"> ) in result
		if(preg_match("/\<\s*orderResponse\s+status\s*\=\s*\"OK\"\\s*[\/]*\s*>/", $result)){
			$got_ok = 1;

			// Now try to get the URL	
			if(preg_match("/\<\s*comment\s+type\s*\=\s*\"url\"\\s*[\/]*\s*>/", $result)){
				if(preg_match("/\[CDATA\[http(.*?)\]\]/", $result, $matches)){
					$got_url = 1;
					$url = 'http'.$matches[1];
				}
			}
		}
	}
	
	if($dbg>0){ echo "$fname: curl_errors = $curl_errors, got_ok = $got_ok, got_url = $got_url, url = ".$url."<br>\n"; }

}



?>
