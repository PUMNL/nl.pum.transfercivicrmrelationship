# nl.pum.transfercivicrmrelationship

This CiviCRM-extension can transfer relationships between contacts.
It will create a new relationships tab with checkboxes before each relationship.
You can use this to select the relationships you want to transfer to another contact.
Then use the button 'Transfer relationship' and select the contact you want to transfer the contact to.
After pressing 'Ok', all selected relationships will be transferred to the selected contact

![Screenshot](https://raw.github.com/PUMNL/nl.pum.transfercivicrmrelationship/master/images/screenshot.png)

The extension is licensed under [AGPL-3.0](LICENSE.txt).

## Requirements

* PHP 5.6 (tested, probably work with other versions too).
* CiviCRM 4.4.8 (tested, might work with other versions too).

## Installation (Web UI)

This extension has not yet been published for installation via the web UI.

## Installation (CLI, Zip)

Sysadmins and developers may download the `.zip` file for this extension and
install it with the command-line tool [cv](https://github.com/civicrm/cv).

```bash
cd <extension-dir>
cv dl nl.pum.transfercivicrmrelationship@https://github.com/PUMNL/nl.pum.transfercivicrmrelationship/archive/master.zip
```

## Installation (CLI, Git)

Sysadmins and developers may clone the [Git](https://en.wikipedia.org/wiki/Git) repo for this extension and
install it with the command-line tool [cv](https://github.com/civicrm/cv).

```bash
git clone https://github.com/PUMNL/nl.pum.transfercivicrmrelationship.git
cv en transfercivicrmrelationship
```

## Configuration after installation

No configuration is required for this extension. Just install/enable it to activate.

## Usage

To transfer a relationship, select the relationship using the checkbox and press 'Transfer Relationship'.
Then you'll get a popup screen where you can select the contact to which you want to transfer the relationship.
After you have selected the contact and press 'Ok', the relationships will be transferred to the selected contact.

## To do

Currently nothing as far as I know.

## Documentation