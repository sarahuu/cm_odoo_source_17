1. Clone Repository
git clone https://github.com/sarahuu/cm_odoo_source_17.git
cd cm_odoo_source_17

2. Create odoo.conf file
nano odoo.conf

3. build docker image
docker build -t cm_odoo_source:17.0 .

4. confirm docker image
docker image ls