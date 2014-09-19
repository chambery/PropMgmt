-- current lease history
select item_name, amount, date, vendor, from_date, to_date from history, leases where history.prop_name = '1313 Mockingbird Ln' and leases.prop_name = '1313 Mockingbird Ln' and leases.from_date <= date('now') and leases.to_date >= date('now') and history.date >= leases.from_date

-- current lease, current month history
select item_name, amount, date, vendor, from_date, to_date from history, leases where history.prop_name = '1313 Mockingbird Ln' and leases.prop_name = '1313 Mockingbird Ln' and leases.from_date <= date('now') and leases.to_date >= date('now') and strftime('%m', history.date) = strftime('%m', date('now'))
