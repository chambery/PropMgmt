import 'dart:html';
import 'dart:convert';
import 'dart:js';
import 'package:intl/intl.dart';


var rows_i = [];

void main()
{
  var request = HttpRequest.getString('/property/1313%20Mockingbird%20Ln/2014-06-01').then(onDataLoaded);
}

void onDataLoaded(String responseText)
{
  var jsonString = responseText;
  print(jsonString);
  /* expecting */
  Map property_data = JSON.decode(jsonString);
  displayPropertyData(property_data);

}

void displayPropertyData(Map property_data)
{
  querySelector('#property_name').appendText("1313 Mockingbird Ln");
  print('$property_data\n');
  print('${property_data['tenants']}\n');

  property_data["tenants"].forEach((tenant)
  {
    Element tenant_div = new DivElement()
      ..id = 'tenants';

    Element tenant_name_div = new DivElement()
      ..classes.add('tenant')
      ..appendText('${tenant['name']}');
    tenant_div.append(tenant_name_div);
    Element contact_points_div = new DivElement()
      ..classes.add('tenant')
      ..id = 'contact_points';

    Element contact_point_div = new DivElement()
      ..classes.add('contact_point')
      ..appendText('${tenant['phone']}');
    contact_points_div.append(contact_point_div);
    tenant_div.append(contact_points_div);

    querySelector('#tenants').append(tenant_div);

  });


  /* handsontable */
  var colHeaders = [''];
  var rows_e = [];


  DateFormat yyyy_MM_dd = new DateFormat('yyyy-MM-dd');
  DateFormat yyyy_MM = new DateFormat('yyyy-MM');
  DateFormat MMM = new DateFormat('MMM');
  DateTime from_date = yyyy_MM_dd.parse(property_data['from_date']);
  DateTime to_date = yyyy_MM_dd.parse(property_data['to_date']);
  Duration duration = to_date.difference(from_date);
  final oCcy = new NumberFormat('#,##0.00', 'en_US');

  DateTime counter = from_date;
  print('$to_date');
  while (counter.isBefore(to_date))
  {
    colHeaders.add(MMM.format(counter));
    /* increment the month */
    counter = new DateTime(counter.year, counter.month + 1, counter.day);
  }

  property_data['by_item_name'].forEach((item_name, months)
  {
    /*
     "rent": {
            "2014-08": {
                "prop_name": "1313 Mockingbird Ln",
                "item_name": "rent",
     */
    var row = [{'view': item_name}];

    DateTime counter = from_date;
    print('$item_name');
    while (yyyy_MM.format(counter).compareTo(yyyy_MM.format(to_date)) <= 0)
    {

      var data ='  ';
      if (property_data['by_item_name'][item_name][yyyy_MM.format(counter)] != null)
      {
        var amount = property_data['by_item_name'][item_name][yyyy_MM.format(counter)]['amount'];
        print('\t${yyyy_MM.format(counter)}: $amount');
        data = oCcy.format(amount * .01);
        if(amount >= 0 && !rows_i.contains(row))
        {
          rows_i.add(row);
        }
        else if(amount < 0 && !rows_e.contains(row))
        {
          rows_e.add(row);
        }
      }
      print('cell: $data');
      var raw_date = property_data['by_item_name'][item_name][yyyy_MM.format(counter)];
      row.add({'view': data, 'data': raw_date });

      /* increment the month */
      counter = new DateTime(counter.year, counter.month + 1, counter.day);
    }
  });

  print('$rows_i\n$rows_e');

  var rows = [];
  rows.addAll(rows_i);
  rows.addAll(rows_e);

  context['Handsontable']['TextCell']['renderer'] = renderCell;

//  var getCellProps = new JsFunction.withThis(getCellProperties);
  var hot_data = new JsObject.jsify({
      'colHeaders': colHeaders,
      'data': rows,
//      'cells': (row, col, map) {
//        print('row: $row, col: $col');
//      },
      'afterChange': (changes, source, a, b, c, d)
      {
        /* changes = [ [row, col, prev, new] ] */
        print('$changes, $source, $a, $b, $c, $d');
        if(changes != null)
        {
          var row = changes[0][0];
          var col = changes[0][1];
          var prev = changes[0][2];
          var val = changes[0][3];
          // TODO - fix up data with type assignment
          /* item_name will always be in the zero column */
          saveCell(property_data['prop_name'], colHeaders[col], rows[row][0], '{"amount": $val}');
        }
      }
  });


  context
    .callMethod('jQuery', ['#handsontable'])
    .callMethod('handsontable', [hot_data]);
//  var hot = new js.JsObject(js.context['Handsontable'], [hot_data]);
//  print('$hot');
}

void saveCell(String prop_name, String date, String category, var data)
{
  print('$prop_name\n$date\n$category\n$data');
    HttpRequest request = new HttpRequest(); // create a new XHR

    // add an event handler that is called when the request finishes
    request.onReadyStateChange.listen((_) {
      if (request.readyState == HttpRequest.DONE &&
      (request.status == 200 || request.status == 0)) {
        // data saved OK.
        print(request.responseText); // output the response from the server
      }
    });

    // POST the data to the server
    var url = "/history/$prop_name/$date/$category";
    request.open("POST", url, async: false);

    request.send(data); // perform the async POST
  }


void renderCell(var instance, var td, int row, int col, var prop, var value, Map cellProperties)
{
  print('renderCell:  $instance, $td, $row, $col, $prop, $value, $cellProperties');
  if(value is Map)
  {
    value.forEach((k,v) => print('$k = $v'));
  }

//  context['Handsontable']['TextRenderer'](instance, td, row, col, prop, value, cellProperties);

}