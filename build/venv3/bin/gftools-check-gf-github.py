#!/Users/stephennixon/type-repos/google-font-repos/inter/build/venv3/bin/python3
# -*- coding: utf-8 -*-
# Copyright 2017 The Fontbakery Authors
# Copyright 2017 The Google Font Tools Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
"""
Report how many github issues/prs were opened and closed for the google/fonts
repository between two specified dates.

Example:
Issues between 2017-01-01 to 2017-06-01:
python fontbakery-check-gf-github.py <user> <pass> 2017-01-01 2017-06-01

The title and url of each issues/pr can be displayed by using the 
-v, --verbose option.
"""
import requests
import re
from datetime import datetime
from argparse import (ArgumentParser,
                      RawTextHelpFormatter)


def get_pagination_urls(request):
    pages = dict(
        [(rel[6:-1], url[url.index('<')+1:-1]) for url, rel in
        [link.split(';') for link in
        request.headers['link'].split(',')]]
    )
    last_page_url = pages['last']
    last_page_no = re.search(r'(?<=&page=)[0-9]{1,20}', last_page_url).group(0)
    base_url = last_page_url.replace(last_page_no, '')

    urls = []
    for n in range(1, int(last_page_no) + 1):
        url = base_url + str(n)
        urls.append(url)
    return urls


def get_issues_paginate(request_issues, start, end, auth):
  """
  If there are too many issues for one page, iterate through the pages
  to collect them all.
  """
  issues = {}
  print 'Getting paginated results, be patient...'
  pages_url = get_pagination_urls(request_issues)

  for page_url in pages_url:
    request = requests.get(page_url, auth=auth)
    page_issues = get_issues(request, start, end)

    for issue_type in page_issues:
      if issue_type not in issues:
        issues[issue_type] = []
      issues[issue_type] = issues[issue_type] + page_issues[issue_type]
  return issues


def get_issues(request_issues, start, end):
  """
  Return a dictionary containing 4 categories of issues
  """
  issues = [i for i in request_issues.json()]
  return {
    "closed_issues": [
      i for i in issues
      if i['closed_at'] and 'pull_request' not in i
      and iso8601_to_date(i['closed_at']) >= start
      and iso8601_to_date(i['closed_at']) <= end
    ],

    "opened_issues": [
      i for i in issues
      if 'pull_request' not in i
      and iso8601_to_date(i['created_at']) >= start
      and iso8601_to_date(i['created_at']) <= end
    ],

    "closed_prs": [
      i for i in issues
      if i['closed_at'] and 'pull_request' in i
      and iso8601_to_date(i['closed_at']) >= start
      and iso8601_to_date(i['closed_at']) <= end
    ],

    "opened_prs": [
      i for i in issues
      if 'pull_request' in i
      and iso8601_to_date(i['created_at']) >= start
      and iso8601_to_date(i['created_at']) <= end
    ],
  }


def output_issues(issues, key):
  for issue in issues[key]:
    title = issue['title'][:50] + '...'
    url = issue['url'].replace('api.github.com/repos/', 'github.com/')
    print '%s\t%s\t%s' % (
      key,
      title.ljust(50, ' ').encode('utf-8'),
      url.encode('utf-8'),
    )


def iso8601_to_date(date_string):
  """Note, this function will strip out the time and tz"""
  date_string = date_string.split('T')[0]
  return datetime.strptime(date_string, "%Y-%m-%d")


def main():
  parser = ArgumentParser(description=__doc__,
                          formatter_class=RawTextHelpFormatter)
  parser.add_argument('username',
                      help="Your Github username")
  parser.add_argument('password',
                      help="Your Github password")
  parser.add_argument('start',
                      help="Start date in ISO 8601 format YYYY-MM-DD")
  parser.add_argument('end',
                      help="End date in ISO 8601 format YYYY-MM-DD")
  parser.add_argument('-v', '--verbose', action='store_true',
                      help="Output all title and urls for prs and issues")
  parser.add_argument('-ci', '--closed-issues',action='store_true',
                      help="Output all closed issues")
  parser.add_argument('-oi', '--opened-issues',action='store_true',
                      help="Output all opened issues")
  parser.add_argument('-cp', '--closed-pulls',action='store_true',
                      help="Output all closed/merged pull requests")
  parser.add_argument('-op', '--opened-pulls',action='store_true',
                      help="Output all opened pull requests")

  args = parser.parse_args()

  start = iso8601_to_date(args.start)
  end = iso8601_to_date(args.end)

  if start > end:
    raise ValueError('start time is greater than end time')

  repo_url = "https://api.github.com/repos/google/fonts/issues"
  
  request_params = {
    'state': 'all',
    'direction': 'asc',
    'since': '2015-03-01', # Date repo was created
    'per_page': 100
  }

  auth = (args.username, args.password)
  request_issues = requests.get(
    repo_url,
    auth=auth,
    params=request_params,
  )

  # Check if issues span more than one page
  if 'link' in request_issues.headers:
    issues = get_issues_paginate(request_issues, start, end, auth)
  else:
    issues = get_issues(request_issues, start, end)

  if args.verbose:
    output_issues(issues, 'closed_issues')
    output_issues(issues, 'opened_issues')
    output_issues(issues, 'closed_prs')
    output_issues(issues, 'opened_prs')
  else:
    if args.closed_issues:
      output_issues(issues, 'closed_issues')
    if args.opened_issues:
      output_issues(issues, 'opened_issues')
    if args.closed_pulls:
      output_issues(issues, 'closed_prs')
    if args.opened_pulls:
      output_issues(issues, 'opened_prs')

  print 'Issues closed\t%s' % len(issues['closed_issues'])
  print 'Issues opened\t%s' % len(issues['opened_issues'])
  print 'Pull requests closed/merged\t%s' % len(issues['closed_prs'])
  print 'Pull requests opened\t%s' % len(issues['opened_prs'])


if __name__ == '__main__':
  main()
