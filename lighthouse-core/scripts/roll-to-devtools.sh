#!/usr/bin/env bash

##
# @license Copyright 2017 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
##

# usage:

#   yarn devtools

# with a custom devtools front_end location:
#   yarn devtools node_modules/temp-devtoolsfrontend/front_end/

chromium_dir="$HOME/chromium/src"

if [[ -n "$1" ]]; then
  frontend_dir="$1"
else
  frontend_dir="$chromium_dir/third_party/blink/renderer/devtools/front_end"
fi

tests_dir="$frontend_dir/../../../web_tests/http/tests/devtools/audits"

if [[ ! -d "$frontend_dir" || ! -a "$frontend_dir/Runtime.js" ]]; then
  echo -e "\033[31m✖ Error!\033[39m"
  echo "This script requires a devtools frontend folder. We didn't find one here:"
  echo "    $frontend_dir"
  exit 1
else
  echo -e "\033[96m ✓\033[39m Chromium folder in place."
fi

report_dir="lighthouse-core/report/html"
fe_lh_dir="$frontend_dir/audits/lighthouse"

lh_bg_js="dist/lighthouse-dt-bundle.js"
lh_worker_dir="$frontend_dir/audits_worker/lighthouse"

# copy lighthouse-dt-bundle (potentially stale)
cp -pPR "$lh_bg_js" "$lh_worker_dir/lighthouse-dt-bundle.js"
echo -e "\033[96m ✓\033[39m (Potentially stale) lighthouse-dt-bundle copied."

# copy report generator + cached resources into $fe_lh_dir
# use dir/* format to copy over all files in dt-report-resources directly to $fe_lh_dir 
# dir/ format behavior changes based on if their exists a folder named dir, which can get weird
cp -r dist/dt-report-resources/* $fe_lh_dir

# update expected version string in tests
VERSION=$(node -e "console.log(require('./package.json').version)")
sed -i '' -e "s/Version:.*/Version: $VERSION/g" "$tests_dir"/*-expected.txt

echo "Done. To rebase the test expectations, run: yarn --cwd ~/chromium/src/third_party/blink/renderer/devtools test 'http/tests/devtools/audits/*' --reset-results"
