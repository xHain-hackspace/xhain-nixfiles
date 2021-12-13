
local f = io.open("/var/lib/dhcp/dhcpd.leases", "r")
local content = f:read("*all")
f:close()

html_header = [[
  <!DOCTYPE html>
  <html>
    <style>
      body {
        background-color:#003a3e;
        font-size:18px;
        color:white;
      }
      table, th, td {
        border-collapse: collapse;
        border:2px solid #fec300;
        padding: 15px;
      }
      table, td {
        font-family: monospace;
      }
    </style>
    <body>
      <table>
        <tr>
          <th>IP</th>
          <th>Mac</th>
          <th>Vendor</th>
          <th>Client Hostname</th>
          <th>DNS</th>
          <th>Starts</th>
          <th>Ends</th>
        </tr>
]]
ngx.print(html_header)

for ip, block in content:gmatch('lease (%C-) (%b{})') do
  client_hostname = string.match(block, 'client%-hostname "(.-)";')
  mac = string.match(block, '.-hardware ethernet %x%x:%x%x:%x%x:(%x%x:%x%x:%x%x);')
  vendor = string.match(block, '.-set vendor%-class%-identifier = "(.-)";')
  dns = string.match(block, '.-set ddns%-fwd%-name = "(.-)";')
  starts = string.match(block, '.-starts (.-);')
  ends = string.match(block, '.-ends (.-);')
  
  ngx.print("<tr>")
  ngx.print("<td>" .. (ip or "-") .. "</td>")
  ngx.print("<td> xx:xx:xx:" .. (mac or "-") .. "</td>")
  ngx.print("<td>" .. (vendor or "-") .. "</td>")
  ngx.print("<td>" .. (client_hostname or "-") .. "</td>")
  ngx.print("<td>" .. (dns or "-") .. "</td>")
  ngx.print("<td>" .. (starts or "-") .. "</td>")
  ngx.print("<td>" .. (ends or "-") .. "</td>")
  ngx.print("</tr>")
end

html_footer = [[
      </table>
    </body>
  </html>
]]
ngx.print(html_footer)

