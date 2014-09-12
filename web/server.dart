import 'package:start/start.dart';
import 'dart:io';
import 'package:http_server/http_server.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:dart-sqlite/sqlite.dart';

YamlMap properties = loadYaml(new File("properties.yaml").readAsStringSync());
YamlMap leases = loadYaml(new File("leases.yaml").readAsStringSync());
YamlMap histories = loadYaml(new File("history.yaml").readAsStringSync());
YamlMap contracts = loadYaml(new File("contracts.yaml").readAsStringSync());
var today = new DateFormat('yyyy-MM-dd').format(new DateTime.now());
var thisYear = new DateFormat('yyyy').format(new DateTime.now());
Database db = new Database.inMemory()
                  ..execute('CREATE TABLE txns (date text, name text, amount real, vendor text, note text');
YamlMap getLease(String prop_name, [String date])
{
  YamlMap propLeases = leases[prop_name];
  print('${propLeases}\n');
  var dateRE = new RegExp(r'(\d{4}-\d{2}-\d{2}) - (\d{4}-\d{2}-\d{2})');
  var propDate = date;
  if (propDate == null)
  {
    propDate = today;
  }

  var leaseResult = JSON.encode('No lease found for ${prop_name} containing ${propDate}');
  for (var date in propLeases.keys)
  {
    print('key: ${date}');
    print('${dateRE}.hasMatch(${date}) == ${dateRE.hasMatch(date)}');
    var match = dateRE.firstMatch(date);
    print('matching ${match}: ');

    var from = match.group(1);
    var to = match.group(2);
    /* propDate >= from && propDate <to */
    if (propDate.compareTo(from) > -1 && propDate.compareTo(to) < 0)
    {
      print('\tfound a match ${from} - ${to}');
      leaseResult = propLeases[date];
      break;
    }
    else
    {
      print('\tno match found for ${propDate} in ${from} - ${to}');
    }

  }

  print('${leaseResult}');
  return leaseResult;
}

void main()
{

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((rec)
  {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  start(port: 3000).then((Server app)
  {

    app.static('web', jail: false);

    /* send all properties */
//    app.get('/').listen((request)
//    {
//      request.response.header('Content-Type', 'text/html; charset=UTF-8').send(properties);
//    });

    /* property page */
    app.get('/property/:prop_name').listen((request)
    {
      var prop_data = {};
      var propName = request.param('prop_name');
      var thisYearHistory = {};
      print('${histories}');
      histories[propName].forEach((name, txn)
      {
        var cols = '(';
        var values = '(';
        txn.forEach((attr, value)
        {
          cols += '${attr}, ';
          values += '${value}, ';
        });
        /* strip trailing commas */
        cols = '${cols.substring(0, cols.length-2)})';
        values = '${values.substring(0, cols.length-2)})';

        db.execute('INSERT INTO txns ${cols} VALUES ${values}');
      });

      db.execute("SELECT * FROM txns", [], (row)
      {
        print('${row}\n');
      });

      prop_data['details'] = properties[propName];
      prop_data['history'] = thisYearHistory;
      prop_data['lease'] = getLease(propName);
      prop_data['contracts'] = contracts[propName];


      request.response.header('Content-Type', 'text/html; charset=UTF-8').send(JSON.encode(prop_data));
    });


    app.get('/:prop_name/lease/:date').listen((request)
    {
      var leaseResult = getLease(request.param('prop_name'), request.param('date'));

      request.response.header('Content-Type', 'text/html; charset=UTF-8').send(leaseResult);
    });

    app.ws('/socket').listen((socket)
    {
      socket.on('connected').listen((data)
      {
        socket.send('ping', 'data-from-ping');
      });

      socket.on('pong').listen((data)
      {
        print('pong: $data');
        socket.close(1000, 'requested');
      });

      socket.onOpen.listen((ws)
      {
        print('new socket opened');
      });

      socket.onClose.listen((ws)
      {
        print('socket has been closed');
      });
    });

    app.static('.');

  });
}
