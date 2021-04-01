<?php
use CRM_Transfercivicrmrelationship_ExtensionUtil as E;

class CRM_Transfercivicrmrelationship_Page_RelationshipsPUM extends CRM_Core_Page {

  protected $clientId;
  protected $_pager;

  /**
   * The action links that we need to display for the browse screen
   *
   * @var array
   * @static
   */
  static $_links = NULL;

  public function run() {
    $this->clientId = '';
    $this->setPageConfiguration();
    $displayRelationships = array();
    $displayInactiveRelationships = array();
    $this->initializePager();
    $daoRelationships = $this->getDaoRelationships();

    while($daoRelationships->fetch()) {
      $row = $this->buildRow($daoRelationships);
      $displayRelationships[] = $row;
    }

    $daoNumActiveRelationships = $this->getNumActiveRelationships();
    $numActiveRelationships = 0;
    while($daoNumActiveRelationships->fetch()) {
      $numActiveRelationships++;
    }

    global $user;

    $canTransferRelationship = FALSE;

    if(user_access('transfer relationships') == TRUE) {
      $canTransferRelationship = TRUE;
    } else {
      $canTransferRelationship = FALSE;
    }

    $this->assign('canTransferRelationship', $canTransferRelationship);
    $this->assign('clientId', $this->clientId);
    $this->assign('relationships', $displayRelationships);
    $this->assign('currentPage',$this->_pager->_currentPage);
    $this->assign('totalPages',$this->_pager->_totalPages);
    $this->assign('numActiveRelationships', $numActiveRelationships);

    parent::run();
  }

  protected function setPageConfiguration() {
    CRM_Utils_System::setTitle(ts('List of relationships'));

    $this->clientId = CRM_Utils_Request::retrieve('cid', 'Positive');
  }

  /**
   * Function to get relationships
   *
   * @return object DAO
   * @access protected
   */
  protected function getDaoRelationships() {
    $params = array();
    list($offset, $limit) = $this->_pager->getOffsetAndRowCount();
    $query = "SELECT DISTINCT rel.id as 'rel_id', rel.contact_id_a, rel.contact_id_b, rel.case_id, rt.label_a_b as 'rel_type', cta.display_name as 'contact_a_name', ctb.display_name as 'contact_b_name', rel.start_date as 'rel_start', rel.end_date as 'rel_end', adra.city as 'rela_city', adrb.city as 'relb_city', ctya.name as 'rela_country', ctyb.name as 'relb_country', emla.email as 'rela_email', emlb.email as 'relb_email', tela.phone AS 'rela_phone', telb.phone AS 'relb_phone', rel.is_active FROM civicrm_relationship rel
              LEFT JOIN civicrm_relationship_type rt ON rt.id = rel.relationship_type_id
              LEFT JOIN civicrm_contact cta ON cta.id = rel.contact_id_a
              LEFT JOIN civicrm_contact ctb ON ctb.id = rel.contact_id_b
              LEFT JOIN civicrm_address adra ON adra.contact_id = rel.contact_id_a AND adra.is_primary = 1
              LEFT JOIN civicrm_address adrb ON adrb.contact_id = rel.contact_id_b AND adrb.is_primary = 1
              LEFT JOIN civicrm_country ctya ON ctya.id = adra.country_id
              LEFT JOIN civicrm_country ctyb ON ctyb.id = adrb.country_id
              LEFT JOIN civicrm_email emla ON emla.contact_id = rel.contact_id_a AND emla.is_primary = 1
              LEFT JOIN civicrm_email emlb ON emlb.contact_id = rel.contact_id_b AND emlb.is_primary = 1
              LEFT JOIN civicrm_phone tela ON tela.contact_id = rel.contact_id_a AND tela.is_primary = 1
              LEFT JOIN civicrm_phone telb ON telb.contact_id = rel.contact_id_b AND telb.is_primary = 1
              WHERE rel.contact_id_a = %1 OR rel.contact_id_b = %1
              ";

    $query .= " ORDER BY is_active DESC,rel.end_date IS NULL DESC,rel.start_date DESC
              LIMIT %2, %3";

    $params = array(1 => array($this->clientId, 'Integer'),
                    2 => array($offset, 'Integer'),
                    3 => array($limit, 'Integer')
    );

    return CRM_Core_DAO::executeQuery($query, $params);
  }

  /**
   * Function to get the number of active relationships
   *
   * @return object DAO
   * @access protected
   */
  protected function getNumActiveRelationships() {
    $params = array(1=> array($this->clientId, 'Integer'));
    $query = "SELECT DISTINCT rel.id as 'rel_id' FROM civicrm_relationship rel
              WHERE (rel.contact_id_a = %1 OR rel.contact_id_b = %1) AND rel.is_active = 1 AND (rel.end_date IS NULL OR rel.end_date > NOW())";
    return CRM_Core_DAO::executeQuery($query, $params);
  }

  /**
   * Fucntion to build the display row
   *
   * @param object $dao
   * @return array
   * @access protected
   */
  protected function buildRow($dao) {
    $displayRow = array();
    $displayRow['rel_id'] = $dao->rel_id;

    $displayRow['current_contact'] = isset($_GET['cid'])?$_GET['cid']:'';
    $displayRow['contact_id_a'] = $dao->contact_id_a;
    $displayRow['contact_id_b'] = $dao->contact_id_b;
    $displayRow['rel_type'] = $dao->rel_type;
    $displayRow['contact_a_name'] = $dao->contact_a_name;
    $displayRow['contact_b_name'] = $dao->contact_b_name;
    $displayRow['case_id'] = $dao->case_id;
    $displayRow['rel_start'] = $dao->rel_start;
    $displayRow['rel_end'] = $dao->rel_end;
    $displayRow['rela_city'] = $dao->rela_city;
    $displayRow['relb_city'] = $dao->relb_city;
    $displayRow['rela_country'] = $dao->rela_country;
    $displayRow['relb_country'] = $dao->relb_country;
    $displayRow['rela_email'] = $dao->rela_email;
    $displayRow['relb_email'] = $dao->relb_email;
    $displayRow['rela_phone'] = $dao->rela_phone;
    $displayRow['relb_phone'] = $dao->relb_phone;
    $displayRow['is_active'] = $dao->is_active;

    $permissions = array(CRM_Core_Permission::VIEW);
    //validate access for all cases.
    $allCases = TRUE;
    if ($allCases && !CRM_Core_Permission::check('access all cases and activities')) {
      $allCases = FALSE;
    }
    if (CRM_Core_Permission::check('access all cases and activities') ||
      (!$allCases && CRM_Core_Permission::check('access my cases and activities'))
    ) {
      $permissions[] = CRM_Core_Permission::EDIT;
    }
    if (CRM_Core_Permission::check('delete in CiviCase')) {
      $permissions[] = CRM_Core_Permission::DELETE;
    }
    $mask = CRM_Core_Action::mask($permissions);
    $actions = CRM_Case_Selector_Search::links();


    $displayRow['actions'] = CRM_Core_Action::formLink($actions['primaryActions'], $mask,
      array(
        'id' => $dao->case_id,
        'cid' => $dao->contact_id_a,
        'cxt' => 'case',
      )
    );

    //Remove action for issue #4389
    if(is_array($actions['moreActions'])){
      foreach($actions['moreActions'] as $key => $value){
        if($actions['moreActions'][$key]['name'] == 'Assign to Another Client'){
          unset($actions['moreActions'][$key]);
        }
      }
    }
    $displayRow['moreActions'] = CRM_Core_Action::formLink($actions['moreActions'],
      $mask,
      array(
        'id' => $dao->case_id,
        'cid' => $dao->contact_id_a,
        'cxt' => 'case',
      ),
      ts('more'),
      TRUE
    );

    return $displayRow;
  }

  /**
   * Method to initialize pager
   *
   * @access protected
   */
  protected function initializePager() {
    if ($this->clientId) {
      try {
        $values = array(
          1 => array($this->clientId, 'Integer')
        );

        $query = "SELECT COUNT(*) FROM (SELECT DISTINCT rel.id as 'rel_id' FROM civicrm_relationship rel
              LEFT JOIN civicrm_relationship_type rt ON rt.id = rel.relationship_type_id
              LEFT JOIN civicrm_contact cta ON cta.id = rel.contact_id_a
              LEFT JOIN civicrm_contact ctb ON ctb.id = rel.contact_id_b
              WHERE (rel.contact_id_a = %1 OR rel.contact_id_b = %1)) as cnt";

        $params           = array(
          'total' => CRM_Core_DAO::singleValueQuery($query, $values),
          'rowCount' => 50,
          'buttonBottom' => 'PagerBottomButton',
          'buttonTop' => 'PagerTopButton',
          'pageID' => $this->get(CRM_Utils_Pager::PAGE_ID),
          'status' => ''
        );

        $this->_pager = new CRM_Utils_Pager($params);
        $this->assign_by_ref('pager', $this->_pager);
      } catch (Exception $ex) {

      }
    }
  }

  /**
   * Get action links
   *
   * @return array (reference) of action links
   * @static
   */
  static function &links() {
    if (!(self::$_links)) {
      $deleteExtra  = ts('Are you sure you want to delete this relationship?');
      $disableExtra = ts('Are you sure you want to disable this relationship?');
      $enableExtra  = ts('Are you sure you want to re-enable this relationship?');

      self::$_links = array(
        CRM_Core_Action::VIEW => array(
          'name' => ts('View'),
          'url' => 'civicrm/contact/view/rel',
          'qs' => 'action=view&reset=1&cid=%%cid%%&id=%%id%%&rtype=%%rtype%%&selectedChild=rel',
          'title' => ts('View Relationship'),
        ),
        CRM_Core_Action::UPDATE => array(
          'name' => ts('Edit'),
          'url' => 'civicrm/contact/view/rel',
          'qs' => 'action=update&reset=1&cid=%%cid%%&id=%%id%%&rtype=%%rtype%%',
          'title' => ts('Edit Relationship'),
        ),
        CRM_Core_Action::ENABLE => array(
          'name' => ts('Enable'),
          'url' => 'civicrm/contact/view/rel',
          'qs' => 'action=enable&reset=1&cid=%%cid%%&id=%%id%%&rtype=%%rtype%%&selectedChild=rel',
          'extra' => 'onclick = "return confirm(\'' . $enableExtra . '\');"',
          'title' => ts('Enable Relationship'),
        ),
        CRM_Core_Action::DISABLE => array(
          'name' => ts('Disable'),
          'url' => 'civicrm/contact/view/rel',
          'qs' => 'action=disable&reset=1&cid=%%cid%%&id=%%id%%&rtype=%%rtype%%&selectedChild=rel',
          'extra' => 'onclick = "return confirm(\'' . $disableExtra . '\');"',
          'title' => ts('Disable Relationship'),
        ),
        CRM_Core_Action::DELETE => array(
          'name' => ts('Delete'),
          'url' => 'civicrm/contact/view/rel',
          'qs' => 'action=delete&reset=1&cid=%%cid%%&id=%%id%%&rtype=%%rtype%%',
          'extra' => 'onclick = "if (confirm(\'' . $deleteExtra . '\') ) this.href+=\'&amp;confirmed=1\'; else return false;"',
          'title' => ts('Delete Relationship'),
        ),
        CRM_Core_Action::NONE => array(
          'name' => ts('Manage Case'),
          'url' => 'civicrm/contact/view/case',
          'qs' => 'action=view&reset=1&cid=%%clientid%%&id=%%caseid%%',
          'title' => ts('Manage Case'),
        ),
      );
    }
    return self::$_links;
  }

}
