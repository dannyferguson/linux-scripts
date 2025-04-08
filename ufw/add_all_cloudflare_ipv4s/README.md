# ufw-cloudflare.sh

This script is handy for keeping the door open for traffic coming from Cloudflare.

**Pro-tip: Set up a cronjob to run this at a steady interval to stay up-to-date**

This can be used with any other website/provider the provides a link to their ips in a text file (in the same format as Cloudflare's, so 1 ip or CIDR per line).

If you want even more security, you can create a tunnel from Cloudflare to your machines directly and keep your firewall closed. For this, read up on [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)