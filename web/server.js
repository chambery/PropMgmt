/**
 * Created by chambery on 8/25/14.
 */
var sqlite3 = require("sqlite3").verbose();
var express = require('express'),
    app = express();
var bodyParser = require("body-parser");
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));
var dateFormat = require('dateformat');
var fs = require('fs');
var file = "../propmgmt.sqlite";
var exists = fs.existsSync(file);
console.log("file exists: " + exists);
var db = new sqlite3.Database(file);
console.log("db: " + db.toString());
YAML = require('yamljs');


function make_dir(path)
{
    try
    {
        fs.lstatSync(path);
    } catch (e)
    {
        fs.mkdirSync(path, 0755);
    }
}

app.get('/property/:prop_name/:from_date', function (req, res)
{
    var now = new Date(Date.now());
    now.setMonth( now.getMonth( ) + 1 );
    txn_history_by_date(req.params.prop_name, req.params.from_date, dateFormat(now, 'yyyy-mm-dd'), function(results) {
        res.header('Content-Type', 'text/json; charset=UTF-8').send(JSON.stringify(results));
    } );

});

/**
 * Returns txn history by month for the supplied property name, between the supplied from and to dates.
 */
app.get('/property/:prop_name/:from_date/:to_date', function(req, res)
{
    txn_history_by_date(req.params.prop_name, req.params.from_date, req.params.to_date, function(results){
        res.header('Content-Type', 'text/json; charset=UTF-8').send(JSON.stringify(results));
    });
});

/**
 *
 */
app.post('/history/:prop_name/:date/:category', function(req, res)
{
    var prop_name = req.params.prop_name;
    var date = req.params.date;
    var cat = req.params.category;

    console.log("property: " + prop_name + ": " + date + ", " + cat);
    console.log("data: " + req.body.data);

    db.serialize(function()
    {
        count = 0;
        console.log("SELECT count(*) FROM history WHERE item_name = '" + cat + "' and strftime('%Y-%m', date) = '" + date + "' and prop_name = '" + prop_name + "')");
        db.get("SELECT count(*) FROM history WHERE item_name = '" + cat + "' and strftime('%Y-%m', date) = '" + date + "' and prop_name = '" + prop_name + "'", function (err, row)
        {
            if(err != null && err.length > 0)
            {
                console.log("error: " + err);
            }
            else if(row != undefined)
            {
                count = row.count;
            }

            if (count == 0)
            {
                console.log("INSERT INTO history VALUES('" + prop_name +"', '" + cat +"', '" + req.body.amount +"', '" + date +"', '" + req.body.vendor +"', '" + req.body.notes +"'");
                db.run("INSERT INTO history VALUES('" + prop_name +"', '" + cat +"', '" + req.body.amount +"', '" + date +"', '" + req.body.vendor +"', '" + req.body.notes +"')");
            }
            else
            {
                console.log("UPDATE history SET prop_name = '" + prop_name +"', item_name = '" + cat +"', date = '" + date +"', amount = " + req.body.amount +"");
                db.run("UPDATE history SET prop_name = '" + prop_name +"', item_name = '" + cat +"', date = '" + date +"', amount = " + req.body.amount +"");
            }

        });



    });
});

app.use('/', express.static(__dirname));
app.listen(1860);
console.log('Express server started on port 1860');

function txn_history_by_date(prop_name, from_date, to_date, fn)
{
    console.log("property: " + prop_name);

    //
    var results = {};
    results['prop_name'] = prop_name;
    results['from_date'] = from_date;
    results['to_date'] = to_date;
    console.log("EXECUTING QUERY: select * from history, leases where history.prop_name = '" + prop_name + "' and history.date >= '" + from_date + "' and date <= '" + to_date + "' AND history.prop_name = leases.prop_name ORDER BY date");
    db.all("select * from history, leases where history.prop_name = '" + prop_name + "' and history.date >= '" + from_date + "' and date <= '" + to_date + "' AND history.prop_name = leases.prop_name ORDER BY date", function (err, rows)
    {
        var by_month = {};
        var by_item_name = {};
        var month_ptrn = /(\d\d\d\d-\d\d).*/;
        console.log("err: " + err);
        console.log("rows: " + rows);
        for (var i in rows)
        {
            /* months */
            var month = month_ptrn.exec(rows[i].date)[1];
            if (month != null)
            {
                console.log(month);
                if (by_month[month] == null)
                {
                    by_month[month] = {"income": [], "expense": []};
                }

                if(rows[i].amount > 0)
                {
                    by_month[month].income.push(rows[i]);
                }
                else
                {
                    by_month[month].expense.push(rows[i]);
                }
            }

            /* item name :: month :: item data */
            var item_name = rows[i].item_name;
            if(by_item_name[item_name] == null)
            {
                by_item_name[item_name] = {};
            }
            by_item_name[item_name][month] = rows[i];
        }
        results["by_month"] = by_month;
        results["by_item_name"] = by_item_name;
        console.log("EXECUTING QUERY: select name, phone, email from tenants, leases, leases_tenants where leases.prop_name = '1313 Mockingbird Ln' and leases.from_date >= '" + from_date + "' and leases.to_date >= '" + to_date + "' and leases.id = leases_tenants.lease_id and tenants.id = leases_tenants.tenant_id");
        // TODO - leases.to_date >= '" + to_date + "' and
        db.all("select name, phone, email from tenants, leases, leases_tenants where leases.prop_name = '1313 Mockingbird Ln' and leases.from_date >= '" + from_date + "' and leases.to_date >= '" + to_date + "' and leases.id = leases_tenants.lease_id and tenants.id = leases_tenants.tenant_id", function (err, rows)
        {
            console.log(err);
            results['tenants'] = rows;
            fn(results);
        });
    });
}
