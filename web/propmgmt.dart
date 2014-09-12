import 'dart:html';
import 'dart:convert';
import 'package:intl/intl.dart';

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
  DateFormat yyyy_MM_dd = new DateFormat('yyyy-MM-dd');
  DateFormat yyyy_MM = new DateFormat('yyyy-MM');
  DateFormat MMM = new DateFormat('MMM');
  DateTime from_date = yyyy_MM_dd.parse(property_data['from_date']);
  DateTime to_date = yyyy_MM_dd.parse(property_data['to_date']);
  Duration duration = to_date.difference(from_date);
  final oCcy = new NumberFormat('#,##0.00', 'en_US');

  TableElement transactions_table = new TableElement();
//  transactions_table.style = 'border: 1px';

  TableRowElement table_header = new TableRowElement();
  /* empty corner cell */
  table_header.addCell().text = ' ';

  DateTime counter = from_date;
  print('$to_date');
  int col_count = 0;
  while (counter.isBefore(to_date))
  {
    table_header.addCell().text = MMM.format(counter);
    /* increment the month */
    counter = new DateTime(counter.year, counter.month + 1, counter.day);
    print('$counter: ${yyyy_MM.format(counter)} < $to_date ?');
    col_count++;
  }

  transactions_table.append(table_header);

  var incomes = new Set();
  var expenses = new Set();

  property_data['by_item_name'].forEach((item_name, months)
  {
    /*
     "rent": {
            "2014-08": {
                "prop_name": "9333 Meadowmont View Dr",
                "item_name": "rent",
     */
    TableRowElement item_row = new TableRowElement();
    item_row.addCell().text = item_name;

    DateTime counter = from_date;
    print('$item_name');
    while (yyyy_MM.format(counter).compareTo(yyyy_MM.format(to_date)) <= 0)
    {

      var data = ' ';
      if (property_data['by_item_name'][item_name][yyyy_MM.format(counter)] != null)
      {
        var amount = property_data['by_item_name'][item_name][yyyy_MM.format(counter)]['amount'];
        print('\t${yyyy_MM.format(counter)}: $amount');
        data = oCcy.format(amount * .01);
        if(amount > 0 && !incomes.contains(item_row))
        {
          print('income: $item_name');
          incomes.add(item_row);
        }
        else if(!expenses.contains(item_row))
        {
          print('expense: $item_name');
          expenses.add(item_row);
        }
      }
      print('cell: $data');
      item_row.addCell().text = data;
      /* increment the month */
      counter = new DateTime(counter.year, counter.month + 1, counter.day);
      print('$counter: ${yyyy_MM.format(counter)} < $to_date ?');
    }
  });

  incomes.forEach((row)
  {
    transactions_table.append(row);
  });

//  var blank_row = ;
  /* add 1 for the blank corner block */
//  blank_row.setAttribute('colspan', '${col_count+1}');
//  blank_row.style.height = '20px';

  transactions_table.appendHtml("<tr><td colspan=${col_count+1}>--</td></tr>  ");

  expenses.forEach((row)
  {
    transactions_table.append(row);
  });


  querySelector('#transactions').append(transactions_table);
}
