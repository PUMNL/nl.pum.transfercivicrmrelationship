<?php

require_once 'transfercivicrmrelationship.civix.php';
use CRM_Transfercivicrmrelationship_ExtensionUtil as E;

/**
 * Implements hook_civicrm_config().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_config/
 */
function transfercivicrmrelationship_civicrm_config(&$config) {
  _transfercivicrmrelationship_civix_civicrm_config($config);
}

/**
 * Implements hook_civicrm_xmlMenu().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_xmlMenu
 */
function transfercivicrmrelationship_civicrm_xmlMenu(&$files) {
  _transfercivicrmrelationship_civix_civicrm_xmlMenu($files);
}

/**
 * Implements hook_civicrm_install().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_install
 */
function transfercivicrmrelationship_civicrm_install() {
  _transfercivicrmrelationship_civix_civicrm_install();
}

/**
 * Implements hook_civicrm_postInstall().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_postInstall
 */
function transfercivicrmrelationship_civicrm_postInstall() {
  _transfercivicrmrelationship_civix_civicrm_postInstall();
}

/**
 * Implements hook_civicrm_uninstall().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_uninstall
 */
function transfercivicrmrelationship_civicrm_uninstall() {
  _transfercivicrmrelationship_civix_civicrm_uninstall();
}

/**
 * Implements hook_civicrm_enable().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_enable
 */
function transfercivicrmrelationship_civicrm_enable() {
  _transfercivicrmrelationship_civix_civicrm_enable();
}

/**
 * Implements hook_civicrm_disable().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_disable
 */
function transfercivicrmrelationship_civicrm_disable() {
  _transfercivicrmrelationship_civix_civicrm_disable();
}

/**
 * Implements hook_civicrm_upgrade().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_upgrade
 */
function transfercivicrmrelationship_civicrm_upgrade($op, CRM_Queue_Queue $queue = NULL) {
  return _transfercivicrmrelationship_civix_civicrm_upgrade($op, $queue);
}

/**
 * Implements hook_civicrm_managed().
 *
 * Generate a list of entities to create/deactivate/delete when this module
 * is installed, disabled, uninstalled.
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_managed
 */
function transfercivicrmrelationship_civicrm_managed(&$entities) {
  _transfercivicrmrelationship_civix_civicrm_managed($entities);
}

/**
 * Implements hook_civicrm_caseTypes().
 *
 * Generate a list of case-types.
 *
 * Note: This hook only runs in CiviCRM 4.4+.
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_caseTypes
 */
function transfercivicrmrelationship_civicrm_caseTypes(&$caseTypes) {
  _transfercivicrmrelationship_civix_civicrm_caseTypes($caseTypes);
}

/**
 * Implements hook_civicrm_angularModules().
 *
 * Generate a list of Angular modules.
 *
 * Note: This hook only runs in CiviCRM 4.5+. It may
 * use features only available in v4.6+.
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_angularModules
 */
function transfercivicrmrelationship_civicrm_angularModules(&$angularModules) {
  _transfercivicrmrelationship_civix_civicrm_angularModules($angularModules);
}

/**
 * Implements hook_civicrm_alterSettingsFolders().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_alterSettingsFolders
 */
function transfercivicrmrelationship_civicrm_alterSettingsFolders(&$metaDataFolders = NULL) {
  _transfercivicrmrelationship_civix_civicrm_alterSettingsFolders($metaDataFolders);
}

/**
 * Implements hook_civicrm_entityTypes().
 *
 * Declare entity types provided by this module.
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_entityTypes
 */
function transfercivicrmrelationship_civicrm_entityTypes(&$entityTypes) {
  _transfercivicrmrelationship_civix_civicrm_entityTypes($entityTypes);
}

/**
 * Implements hook_civicrm_thems().
 */
function transfercivicrmrelationship_civicrm_themes(&$themes) {
  _transfercivicrmrelationship_civix_civicrm_themes($themes);
}

// --- Functions below this ship commented out. Uncomment as required. ---

/**
 * Implements hook_civicrm_preProcess().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_preProcess
 *
function transfercivicrmrelationship_civicrm_preProcess($formName, &$form) {

} // */

/**
 * Implements hook_civicrm_navigationMenu().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_navigationMenu
 *
function transfercivicrmrelationship_civicrm_navigationMenu(&$menu) {
  _transfercivicrmrelationship_civix_insert_navigation_menu($menu, 'Mailings', array(
    'label' => E::ts('New subliminal message'),
    'name' => 'mailing_subliminal_message',
    'url' => 'civicrm/mailing/subliminal',
    'permission' => 'access CiviMail',
    'operator' => 'OR',
    'separator' => 0,
  ));
  _transfercivicrmrelationship_civix_navigationMenu($menu);
} // */

/**
 * Implementation of hook civicrm_tabs
 * to add a contact segment tab to the contact summary
 *
 * @param array $tabs
 * @param int $contactID
 * @link http://wiki.civicrm.org/confluence/display/CRMDOC/hook_civicrm_tabs
 */
function transfercivicrmrelationship_civicrm_tabs(&$tabs, $contactID) {
  $weight = 0;

  $weight = 0;
  foreach ($tabs as $tabId => $tab) {
    if ($tab['id'] == 'rel') {
      $weight = $tab['weight']++;
    }
  }

  $count = CRM_Core_DAO::singleValueQuery("SELECT COUNT(*) FROM (
SELECT DISTINCT rel.id as 'rel_id' FROM civicrm_relationship rel
WHERE rel.contact_id_a = %1  AND rel.is_active = %2 AND (rel.end_date IS NULL OR rel.end_date > NOW())
UNION
SELECT DISTINCT rel.id as 'rel_id' FROM civicrm_relationship rel
WHERE rel.contact_id_b = %1 AND rel.is_active = %2 AND (rel.end_date IS NULL OR rel.end_date > NOW())
) as cnt", array(1=>array((int)$contactID,'Integer'),2=>array((int)1, 'Integer')));
    //civicrm_api('Relationship', 'getcount', array('version' => 3,'sequential' => 1,'contact_id' => $contactID, 'is_active' => 1, 'end_date'=>NULL));

  //Remove old tab 'Relationships'
  foreach($tabs as $key => $tab) {
    if($tab['id'] == 'rel'){
      unset($tabs[$key]);
    }
  }

  $tabs[] = array(
    'id'      => 'relationshipsPUM',
    'url'     => CRM_Utils_System::url('civicrm/relationshipspum', 'snippet=1&cid='.$contactID),
    'title'   => 'Relationships PUM',
    'weight'  => $weight,
    'count'   => $count
  );
}

/**
 * Implements hook_civicrm_permission
 *
 * @param $permissions
 * @link http://wiki.civicrm.org/confluence/display/CRMDOC/hook_civicrm_permission
 */
function transfercivicrmrelationship_civicrm_permission(&$permissions) {
  $prefix = ts('CiviCRM Transfer Relationships') . ': ';
  $permissions['transfer relationships'] = $prefix . ts('transfer relationships');
}
function transfercivicrmrelationship_civicrm_alterAPIPermissions($entity, $action, &$params, &$permissions) {
  $permissions['relationship']['create'] = array('transfer relationships');
  $permissions['relationship']['update'] = array('transfer relationships');
  $permissions['relationship']['delete'] = array('transfer relationships');
}