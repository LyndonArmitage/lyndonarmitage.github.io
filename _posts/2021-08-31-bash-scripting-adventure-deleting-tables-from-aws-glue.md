---
layout: post
title: 'Bash Scripting Adventure: Deleting tables from AWS Glue'
tags:
- bash
- linux
- aws
- glue
- database
- table
- cli
date: 2021-08-31 18:13 +0100
---
Recently, I was tasked with deleting a load of extraneous tables that made
their way into one of our [AWS Glue](https://aws.amazon.com/glue/) Catalogs.
These tables were causing a major issue by virtue of a fact that there were
15,000+ of them. To solve this problem I applied a bit of Bash scripting that I
thought I'd share.

Now, I am not an expert at Bash but I can use a search engine, and I can break
a problem down and come up with a solution.

The problem here was that our AWS Glue Catalog had a Database that had been
somehow corrupted with a mass of tables by mistake. Doubtless this was due to a
badly configured Glue Crawler that was run by mistake. Said crawler has already
been deleted but the damage was already done. We were left with a database
containing several thousand extra tables. So how do we solve said problem?

The first step is to identify these tables in question. Initially I ran this
simple set of commands to output all the tables in the given database:

```bash
aws glue get-tables \
  --region="eu-west-1" \
  --database-name="our_dev_db" \
  | jq '.TableList[].Name' > all-tables.txt
```

This uses a simple `aws cli` command to list all the tables in the database,
then `jq` to extract just the names of said tables. Given the count of tables
and the size of the JSON response I opted to pipe this into a file
appropriately named `all-tables.txt`.

This file ends up containing a single table name per line, surrounded in double
quotes. Something like the following:

```txt
"table1"
"table2"
"table3"
"table3"
"table4"
"00"
"000002_csv"
"000002_csv_6d0831d01bdc85054d10c4e6ecd7928a"
"000002_csv_79b2db404cc6166f3bf22fb5dacb189a"
"000002_csv_7a6dfd616938f0048fe823fc6eb289f0"
"000002_csv_7b92742bd466480b1829e08b1f606979"
"000002_csv_b71b63958fbc942bd201fbb7fbf8b191"
"000002_csv_d36ac408b17f41f42b7f2a9317c58c18"
"1a_016db0f06b0fb00d885873c893e8f3e5"
"1a_28a42fa1db36f848352bc8588f0b9847"
"1a_453df6626ce46fdc3ea3fb6fa930a4b1"
"1a_4dd57462cabe17550154663676c187a3"
"1a_6a717a38795521182da267f56b3ab073"
"1a_86d42646f916945e13f2b4092ba92f27"
```

It was here I noticed the pattern with most of the bad "tables". They were
working files used by another application writing to the bucket that was being
crawled. This set up a limitation: I can't just delete all the bad data from
S3. That means a simple solution of deleting the whole database and re-running
a crawler is out.

Still, I could have dropped the database and run a crawler with more specific
settings that ignored any of these paths. However, we've had issues with Glue
Crawlers in the past, and we want to avoid them as a result. One example of an
issue we encountered was that they don't always play nicely with partitioning
in S3, resulting in data that is partitioned by dates using `text` data types.

So my next step was to isolate the good tables in `our_dev_db`. This proved
easy enough. In this particular database we followed a naming convention for
our tables. Each has one of a few prefixes. This means that with a simple
`grep` I extracted just the bad tables:

```bash
egrep -v "^\"(fact_|dim_|lku?p_)" all-tables.txt > bad-tables-only.txt
```

Now `bad-tables-only.txt` just contains the bad tables. Fantastic, the next
step is to delete these in AWS. Thankfully, there is a
[batch-delete-table](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/glue/batch-delete-table.html)
command in the `aws cli`. Unfortunately, this command takes a list of
`tables-to-delete` on the command line rather than a file.

Now, bare in mind `bad-table-only.txt` contains over 15,000 table names, many
of which contain a UUID. That's a lot of text. I am certain it breaches some
limit, either in the `aws cli`, HTTP specification, or shell itself. So I opted
to split the data in `bad-tables-only.txt` into multiple files using the
`split` program:

```bash
split -l 100 bad-tables-only.txt split/
```

I limited each file to a maximum of 100 lines, and was left with over 150
files.

Here comes the more involved Bash scripting. I needed to take each of these
files and construct an `aws glue batch-delete-table` command out of their
contents. This isn't hard. All I did was loop through each file, run a `paste`
command on their contents to get the contents on a single line, and output the
resulting `aws cli` command to a file:

```bash
#!/bin/bash

FILES="split/*"
OUTPUT_FILE="run-commands.sh"
DATABASE="our_dev_db"
REGION="eu-west-1"

echo "#!/bin/bash" > $OUTPUT_FILE
echo "# Delete Table Commands" >> $OUTPUT_FILE
for file in $FILES
do
  echo "Processing $file"
  echo "# $file" >> $OUTPUT_FILE

  TABLE_COUNT=$(wc -l $file | awk '{print $1}')
  TABLES=$(cat $file | paste -sd " ")

  printf "echo \"Deleting $TABLE_COUNT tables from $file\" \n" >> $OUTPUT_FILE
  printf "aws glue batch-delete-table \\\\\n" >> $OUTPUT_FILE
  printf "\t --no-cli-pager \\\\\n" >> $OUTPUT_FILE
  printf "\t --region \"$REGION\" \\\\\n" >> $OUTPUT_FILE
  printf "\t --database-name \"$DATABASE\" \\\\\n" >> $OUTPUT_FILE
  printf "\t --tables-to-delete $TABLES \n" >> $OUTPUT_FILE
  printf "echo \"Deleted for $file\"\n" >> $OUTPUT_FILE
  printf "echo \"Processed $file\" >> processed.files\n" >> $OUTPUT_FILE
  printf "sleep 1\n" >> $OUTPUT_FILE
  printf "\n" >> $OUTPUT_FILE
done

chmod +x $OUTPUT_FILE
```

It may not be the most elegant solution, but it works well and is easy to
extend.

That produces a long Bash script file that can be run. The script will output a
note to a `processed.files` file of its progress, and even sleeps for a second
to allow for rate limiting.

Now, the beauty of Bash scripting means that I could easily extend this to do a
little more. I could even incorporate the earlier steps I did manually.

After, running this script `our_dev_db` is now ~15,000 tables lighter.
Hopefully this was interesting to some. It probably took longer to write this
process up than to both come up with and run the script, but I felt like
sharing.
