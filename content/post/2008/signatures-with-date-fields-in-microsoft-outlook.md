---
title: Signatures With Date Fields In Microsoft Outlook
date: 2008-03-03 17:43:19
categories:
  - Technical
---

Ok, so today our CEO said he wanted everybody to stamp their emails with the sending date. It's very simple to just add the date manually, but as you know, a good engineer is a lazy engineer. So this is how I did it:<!--more-->

Add "$$MYDATE$$" to your signature but without the quotes, then add this simple script to VBA:

```plaintext
Private Sub Application_ItemSend(ByVal Item As Object, Cancel As Boolean)
    If Item.Class = olMail Then
        Dim Signature As String
        Signature = Format(Now(), "d/m/yyyy")
        Item.HTMLBody = Replace(Item.HTMLBody, "$$MYDATE$$", Signature, , 1)
    End If
End Sub
```

This should do it. This script will replace $$MYDATE$$ with the current date as soon as you hit the "Send" button. So you will still see "$$MYDATE$$" while you're typing the message.

Just make sure you lower the macro security to medium.

Hope that helps