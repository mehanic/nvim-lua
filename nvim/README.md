# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

![working with Snack1](screenshot_1.png)  
![working with Snack2](screenshot_2.png)
![working with Snack3](screenshot_3.png)

```

:lua Snacks.picker.highlights({pattern = "hl_group:^Snacks"})

SnacksPickerIconEnumMember
SnacksFooter
SnacksPickerFooter
SnacksPickerLabel
SnacksPickerBox
SnacksPickerGitStatusCopied
SnacksPickerGitStatusRenamed
SnacksPickerList
SnacksPickerInput
SnacksPickerPreview
SnacksPickerBoxCursorLine
SnacksPickerInputCursorLine
SnacksPickerListTitle
SnacksDashboardTerminal
SnacksPickerIconEnum
SnacksPickerPreviewTitle
SnacksPickerBoxBorder
SnacksPickerListBorder
SnacksPickerIconBoolean
SnacksPickerPreviewBorder
SnacksPickerToggleRegex
SnacksPickerIconStruct
SnacksPickerToggleFollow
SnacksPickerToggleHidden
SnacksPickerToggleIgnored
SnacksPickerToggleModified
SnacksPickerIconKey
SnacksWinBarNC
SnacksPickerBoxFooter
SnacksPickerListFooter
SnacksPickerInputFooter
SnacksPickerPreviewFooter

# example  Жовті кружечки — це позначки Git-статусу (змінені файли) або LSP-попередження.

Extmarks
  - SnacksPickerGitStatusModified links to DiagnosticWarn

SnacksPickerGitStatusModified = {
  default = true,
  link = "DiagnosticWarn"
}

DiagnosticWarn = {
  bold = true,
  cterm = {
    bold = true
  },
  fg = "#FFCB6B"
}




```
