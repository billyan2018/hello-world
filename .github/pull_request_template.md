# Developer
- [ ] Changes (to java code) have been covered by unite test.
- [ ] All unit tests are passed.
- [ ] The code follows the [company Software Development Standard](https://confluence.kingland.com/display/KPALP/Software+Development+Standard).
- [ ] [Common coding issues](https://confluence.kingland.com/display/~biyan@ksd.kingland.cc/Common+Java+Code+Issues) are not introduced.
- [ ] The latest code from the destination branch has been merged to the source branch.
- [ ] Build runs successfully locally.
- [ ] When implement code changes, try to minimize the scope of change and avoid changing the behavior of other components. 
- [ ] If the change is to apply to a small part of a method, try to extract that specific part as a separate method first. 
  - [ ] Consider adding inline code commenting related to the changes to prevent the code from un-intended update and the defect re-introduced later.
- [ ] Update JIRA ticket with a brief Change summary including the following:
  - [ ] What has been changed;
  - [ ] Acceptance criteria to verify the change;
- [ ] PR name should follows the format of: `[Feature/Defect]/{Task number} {Task summary} `

# Reviewer
- [ ] All changed files need to be reviewed. During reviewing, make sure "Reviewed" checkbox is checked. 
- [ ] All java code changes must be covered with unit test, at least a positive scenario and a negative one
- [ ] Ensure code and comments are meaningful and have good readability.
- [ ] Ensure Common coding issues are not introduced.
- [ ] Ensure the change is also reviewed by tech lead before merge if:
- [ ] Changes to shared components
- [ ] Defect is introduced by another defect
# Tech lead
- [ ] Need to review when
  - [ ] Changes to shared components
  - [ ] Defect is introduced by another defect
