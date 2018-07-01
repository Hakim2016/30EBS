CREATE OR REPLACE PACKAGE XXPA_PROJ_PUBLIC_PVT AUTHID CURRENT_USER IS
  /* $Header: cuxpapub.pls 120.3 2012-02-06 16:10:20 Siman ship $ */

  /*=================================================================
   Copyright (C) HAND Enterprise Solutions Co.,Ltd.
                AllRights Reserved
    =================================================================
  * =================================================================
  *   PROGRAM NAME:
  *                xxpa_proj_public_pvt
  *   DESCRIPTION:
  *                PA:Project,Top Task,Task,Customer,Contact,Agreements API
  *   HISTORY:
  *     1.00  2012-01-11   Hand       Created
  *
  * ===============================================================*/
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  CHECK_CUSTOMER_VALID
  *
  *   DESCRIPTION: Check Customer is validate
  *
  *   ARGUMENT:
  *
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 2012-02-06 Siman.he
  *                     Creation Description
  * =============================================*/

  PROCEDURE UPDATE_PROJ_KEY_MEMBER(P_PROJECT_ID     IN NUMBER,
                                   P_EFFECTIVE_DATE IN DATE,
                                   X_RETURN_STATUS  OUT VARCHAR2,
                                   X_MSG_COUNT      OUT NUMBER,
                                   X_MSG_DATA       OUT VARCHAR2);
  /*==================================================
  Program Name:
      create_proj_manager
  Description:
      create project key member project_manager
  History:
      1.00  2012/2/29 0:31:17  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE CREATE_PROJ_MANAGER(P_PROJECT_ID     IN NUMBER,
                                P_EMPLOYEE_ID    IN NUMBER,
                                P_EFFECTIVE_DATE IN DATE,
                                P_DEBUG_MODE     IN VARCHAR2,
                                X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
                                X_MSG_COUNT      OUT NOCOPY NUMBER,
                                X_MSG_DATA       OUT NOCOPY VARCHAR2);

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  ADD_PROJECT
  *
  *   DESCRIPTION: Create an new Project from Copy a PA:project's Template
  *
  *   ARGUMENT:   p_orig_project_id     Source Project Id
  *               p_long_name           Project's Long name
  *               p_description         Project's Description
  *               p_effective_date      Project's Start Date
  *               p_debug_flag          Debug Flag
  *   RETURN:
  *               x_new_project_number Project Number
  *               x_project_id         Project ID
  *               x_return_status      API Process Status
  *   HISTORY:
  *     1.00 2012-02-06 Siman.he
  *                     Creation Description
  * =============================================*/
PROCEDURE ADD_PROJECT(P_ORIG_PROJECT_ID    IN NUMBER,
                        P_PROJ_NUM           IN VARCHAR2,
                        P_PROJECT_NAME       IN VARCHAR2 := FND_API.G_MISS_CHAR,
                        P_LONG_NAME          IN VARCHAR2,
                        P_DESCRIPTION        IN VARCHAR2,
                        P_EFFECTIVE_DATE     IN DATE,
                        P_START_DATE         IN DATE := FND_API.G_MISS_DATE,
                        P_COMPLETION_DATE    IN DATE := FND_API.G_MISS_DATE,
                        P_COPY_TASK_FLAG     IN VARCHAR2 := 'Y',
                        P_DEBUG_FLAG         IN VARCHAR2 DEFAULT 'N',
                        X_PROJECT_ID         OUT NUMBER,
                        X_NEW_PROJECT_NUMBER OUT VARCHAR2,
                        X_RETURN_STATUS      OUT VARCHAR2,
                        X_MSG_COUNT          OUT NUMBER,
                        X_MSG_DATA           OUT VARCHAR2);

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  ADD_PROJECT_CUSTOMER
  *
  *   DESCRIPTION: Create Horizontal Plan, logic
  *
  *   ARGUMENT:
  *
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 mm/dd/yyyy siman.he
  *                     Creation Description
  * =============================================*/
  PROCEDURE ADD_PROJ_CUSTOMER(P_PROJECT_ID          IN NUMBER,
                              P_CUSTOMER_ID         IN NUMBER,
                              P_BILL_TO_ADDRESS_ID  IN NUMBER,
                              P_SHIP_TO_ADDRESS_ID  IN NUMBER,
                              P_CUSTOMER_BILL_SPLIT IN NUMBER,
                              P_INV_CURRENCY_CODE   IN VARCHAR2,
                              P_ORG_ID              IN NUMBER,
                              X_RETURN_STATUS       OUT VARCHAR2,
                              X_MSG_COUNT           OUT NUMBER,
                              X_MSG_DATA            OUT VARCHAR2);
  /* =============================================
  *   PROCEDURE
  *   NAME :  ADD_PRJ_TASK
  *
  *   DESCRIPTION: If DRP's workbench bucket date is not exists ,The program
  *                Units will be generate a new workbench bucket date
  *
  *   ARGUMENT:
  *
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 mm/dd/yyyy Author Name
  *                     Creation Description
  * =============================================*/
  PROCEDURE ADD_PROJ_TASK(P_PROJECT_ID            NUMBER,
                          P_STRUCTURE_VERSION_ID  NUMBER,
                          P_TASK_NAME             VARCHAR2,
                          P_TASK_NUMBER           VARCHAR2,
                          P_TASK_DESCRIPTION      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                          P_SCHEDULED_START_DATE  DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                          P_SCHEDULED_FINISH_DATE DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                          P_PARENT_TASK_ID        NUMBER,
                          P_TASK_TYPE             NUMBER,
                          X_TASK_ID               OUT NUMBER,
                          X_RETURN_STATUS         OUT VARCHAR2,
                          X_MSG_COUNT             OUT NUMBER,
                          X_MSG_DATA              OUT VARCHAR2);
  /*==================================================
  Program Name:
      update_proj_task
  Description:
      update project task
  History:
      1.00  2012/2/29 21:33:33  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE UPDATE_PROJ_ELEMENT(P_DEBUG_MODE            IN VARCHAR2 := 'N',
                                P_CHARGEABLE_FLAG       IN VARCHAR2,
                                P_PROJ_ELEMENT_ID       IN NUMBER,
                                P_ELEMENT_NUMBER        IN VARCHAR2,
                                P_ELEMENT_NAME          IN VARCHAR2,
                                P_RECORD_VERSION_NUMBER IN NUMBER, --pa_proj_elements.record_version_number
                                -- xxlu added task DFF attributes
                                P_TK_ATTRIBUTE_CATEGORY IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE1         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE2         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE3         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE4         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE5         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE6         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE7         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE8         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE9         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE10        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
                                X_MSG_COUNT             OUT NOCOPY NUMBER,
                                X_MSG_DATA              OUT NOCOPY VARCHAR2);
  /*==================================================
  Program Name:
      add_task_resource_assignment
  Description:
      add task resource assignment
  History:
      1.00  2012/2/29 16:17:48  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE ADD_TASK_RESOURCE_ASSIGNMENT(P_PROJECT_ID IN NUMBER,
                                         /* p_pa_structure_version_id  IN NUMBER,*/
                                         P_TASK_ID                  IN NUMBER,
                                         PA_TASK_ELEMENT_VERSION_ID IN NUMBER,
                                         P_RESOURCE_LIST_MEMBER_ID  IN NUMBER,
                                         P_PLANNED_QUANTITY         IN NUMBER,
                                         P_PM_PRODUCT_CODE          IN VARCHAR2,
                                         P_PM_TASK_ASGMT_REFERENCE  IN VARCHAR2,
                                         X_RETURN_STATUS            OUT NOCOPY VARCHAR2,
                                         X_MSG_COUNT                OUT NOCOPY NUMBER,
                                         X_MSG_DATA                 OUT NOCOPY VARCHAR2);
  /*==================================================
  Program Name:
      delete_proj_task
  Description:
      delete project task
  History:
      1.00  2012/2/29 10:21:04  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE DELETE_PROJ_TASK(P_PROJECT_ID    IN NUMBER,
                             P_TASK_ID       IN NUMBER,
                             X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                             X_MSG_COUNT     OUT NOCOPY NUMBER,
                             X_MSG_DATA      OUT NOCOPY VARCHAR2);

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  ADD_AGREEMENTS
  *
  *   DESCRIPTION:
  *
  *   ARGUMENT: p_customer_id       Customer ID
  *             p_org_id            Org ID
  *             p_agreement_num     Agreement Number
  *             p_agreement_type    Original Agreemnet/VO Agreement
  *             p_agreement_amount  Amount
  *             p_currency_code     Agreemnet Currency Code
  *             p_cust_order_number GOE Interface Customer PO
  *   RETURN:
  *             x_agreement_id      Agreement_id
  *   HISTORY:
  *     1.00 2012-01-11 Siman.he
  *
  * =============================================*/
  PROCEDURE ADD_AGREEMENTS(P_PROJECT_ID        IN NUMBER,
                           P_CUSTOMER_ID       IN NUMBER,
                           P_ORG_ID            IN NUMBER,
                           P_AGREEMENT_NUM     IN VARCHAR2,
                           P_AGREEMENT_TYPE    IN VARCHAR2,
                           P_ALLOCATED_AMOUNT  IN NUMBER,
                           P_CURRENCY_CODE     IN VARCHAR2,
                           P_CUST_ORDER_NUMBER IN VARCHAR2,
                           P_EFFECTIVE_DATE    IN DATE DEFAULT SYSDATE,
                           P_DEBUG_FLAG        IN VARCHAR2 DEFAULT 'N',
                           X_AGREEMENT_ID      OUT NUMBER,
                           X_MSG_COUNT         OUT NUMBER,
                           X_RETURN_STATUS     OUT VARCHAR2,
                           X_MSG_DATA          OUT VARCHAR2);

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  ADD_AGREEMENTS_FUNDING
  *
  *   DESCRIPTION:
  *
  *   ARGUMENT: p_project_id        Project ID
  *             p_agreement_id      Agreement ID
  *             p_allocated_amount  Agreement's Funding Amount
  *             p_date_allocated    Funding's Date Allocated
  *             p_task_id           Project Task ID
  *   RETURN:
  *             x_project_funding_id      Project Funding ID
  *   HISTORY:
  *     1.00 2012-01-11 Siman.he
  *
  * =============================================*/
  PROCEDURE ADD_FUNDING(P_PROJECT_ID         IN NUMBER,
                        P_AGREEMENT_ID       IN NUMBER,
                        P_ALLOCATED_AMOUNT   IN NUMBER,
                        P_DATE_ALLOCATED     IN DATE,
                        P_TASK_ID            IN NUMBER,
                        P_ATTRIBUTE_CATEGORY IN VARCHAR2,
                        P_ATTRIBUTE1         IN VARCHAR2,
                        P_ATTRIBUTE2         IN VARCHAR2,
                        P_ATTRIBUTE3         IN VARCHAR2,
                        P_ATTRIBUTE4         IN VARCHAR2,
                        P_ATTRIBUTE5         IN VARCHAR2,
                        P_ATTRIBUTE6         IN VARCHAR2,
                        P_ATTRIBUTE7         IN VARCHAR2,
                        P_ATTRIBUTE8         IN VARCHAR2,
                        P_ATTRIBUTE9         IN VARCHAR2,
                        P_ATTRIBUTE10        IN VARCHAR2,
                        X_PROJECT_FUNDING_ID IN OUT NUMBER,
                        X_MSG_COUNT          OUT NUMBER,
                        X_RETURN_STATUS      OUT VARCHAR2,
                        X_MSG_DATA           OUT VARCHAR2);
  /*==================================================
  Program Name:
      copy_tasks_in_bulk
  Description:
      copy task in bulk
  History:
      1.00  2012/3/4 22:34:54  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE COPY_TASKS_IN_BULK(P_DEBUG_MODE               IN VARCHAR2 := 'N',
                               P_SRC_PROJECT_ID           IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                               P_SRC_TASK_VERSION_ID      IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                               P_SRC_STRUCTURE_VERSION_ID IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                               --   p_src_task_version_id_tbl   IN system.pa_num_tbl_type := system.pa_num_tbl_type(),
                               P_DEST_STRUCTURE_VERSION_ID IN NUMBER,
                               P_DEST_TASK_VERSION_ID      IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                               P_DEST_PROJECT_ID           IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                               P_PREFIX                    IN VARCHAR2,
                               P_PEER_OR_SUB               IN VARCHAR2 := 'PEER',
                               X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
                               X_MSG_COUNT                 OUT NOCOPY NUMBER,
                               X_MSG_DATA                  OUT NOCOPY VARCHAR2);
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  update_project_customer
  *
  *   DESCRIPTION: update an project's Customer
  *
  *   ARGUMENT:
  *
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 mm/dd/yyyy ouzhiwei
  *                     Creation Description
  * =============================================*/
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  update_project_customer
  *
  *   DESCRIPTION: update an project's Customer
  *
  *   ARGUMENT:
  *
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 mm/dd/yyyy ouzhiwei
  *                     Creation Description
  * =============================================*/
  PROCEDURE UPDATE_PROJECT_CUSTOMER(P_PROJECT_ID                IN NUMBER,
                                    P_CUSTOMER_ID               IN NUMBER,
                                    P_RECORD_VERSION_NUMBER     IN NUMBER,
                                    P_BILL_TO_ADDRESS_ID        IN NUMBER,
                                    P_SHIP_TO_ADDRESS_ID        IN NUMBER,
                                    P_PROJECT_RELATIONSHIP_CODE IN VARCHAR2,
                                    P_CUSTOMER_BILL_SPLIT       IN NUMBER,
                                    /*   p_org_id                IN NUMBER,*/
                                    P_INV_CURRENCY_CODE IN VARCHAR2,
                                    P_INV_RATE_TYPE     IN VARCHAR2,
                                    X_RETURN_STATUS     OUT VARCHAR2,
                                    X_MSG_COUNT         OUT NUMBER,
                                    X_MSG_DATA          OUT VARCHAR2);
  /*==================================================
  Program Name:
      Update_Schedule_Version
  Description:
      Update Schedule Version
  History:
      1.00  2012/4/19 10:21:04  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE UPDATE_SCHEDULE_VERSION(P_PEV_SCHEDULE_ID       IN NUMBER,
                                    P_RECORD_VERSION_NUMBER IN NUMBER,
                                    P_SCHEDULED_START_DATE  IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                                    P_SCHEDULED_END_DATE    IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                                    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
                                    X_MSG_COUNT             OUT NOCOPY NUMBER,
                                    X_MSG_DATA              OUT NOCOPY VARCHAR2);
  /*==================================================
  Program Name:
      Create_Schedule_Version
  Description:
      Create Schedule Version
  History:
      1.00  2012/4/20 10:21:04  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE CREATE_SCHEDULE_VERSION(P_ELEMENT_VERSION_ID    IN NUMBER,
                                    P_RECORD_VERSION_NUMBER IN NUMBER,
                                    P_SCHEDULED_START_DATE  IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                                    P_SCHEDULED_END_DATE    IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                                    X_PEV_SCHEDULE_ID       OUT NOCOPY NUMBER,
                                    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
                                    X_MSG_COUNT             OUT NOCOPY NUMBER,
                                    X_MSG_DATA              OUT NOCOPY VARCHAR2);
  /*==================================================
  Program Name:
      structure_published
  Description:
      structure published
  History:
      1.00  2012/5/29 15:08:00  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE STRUCTURE_PUBLISHED(P_PROJECT_ID              IN NUMBER,
                                X_PUBLISHED_STRUCT_VER_ID OUT NOCOPY NUMBER,
                                X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
                                X_MSG_COUNT               OUT NOCOPY NUMBER,
                                X_MSG_DATA                OUT NOCOPY VARCHAR2);
  /*==================================================
  Program Name:
      update_task_assignments
  Description:
      update task assignments
  History:
      1.00  2012/5/29 15:08:00  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE UPDATE_TASK_ASSIGNMENTS(P_PROJECT_ID         IN NUMBER,
                                    P_PLANNED_QUANTITY   IN NUMBER,
                                    P_TASK_ASSIGNMENT_ID IN NUMBER,
                                    X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
                                    X_MSG_COUNT          OUT NOCOPY NUMBER,
                                    X_MSG_DATA           OUT NOCOPY VARCHAR2);
  /*==================================================
  Program Name:
      TASKS_ROLLUP
  Description:
      Update TASKS_ROLLUP Version
  History:
      1.00  2012/6/14 10:21:04  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE TASKS_ROLLUP(P_ELEMENT_VERSION_ID IN NUMBER,
                         X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
                         X_MSG_COUNT          OUT NOCOPY NUMBER,
                         X_MSG_DATA           OUT NOCOPY VARCHAR2);
  /*==================================================
  Program Name:
      Update_Structure_Version_Attr
  Description:
      update Structure Version_Attr
  History:
      1.00  2012/7/24 15:08:00  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE Update_Structure_Version_Attr(p_pev_structure_id       IN NUMBER,
                                          p_structure_version_name IN NUMBER,
                                          p_record_version_number  IN NUMBER,
                                          X_RETURN_STATUS          OUT NOCOPY VARCHAR2,
                                          X_MSG_COUNT              OUT NOCOPY NUMBER,
                                          X_MSG_DATA               OUT NOCOPY VARCHAR2);
PROCEDURE CREATE_PROJECT_PUB(P_API_VERSION                  IN NUMBER := 1.0,
                               P_INIT_MSG_LIST                IN VARCHAR2 := FND_API.G_TRUE,
                               P_COMMIT                       IN VARCHAR2 := FND_API.G_FALSE,
                               P_VALIDATE_ONLY                IN VARCHAR2 := FND_API.G_TRUE,
                               P_VALIDATION_LEVEL             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                               P_CALLING_MODULE               IN VARCHAR2 := 'SELF_SERVICE',
                               P_DEBUG_MODE                   IN VARCHAR2 := 'N',
                               P_MAX_MSG_COUNT                IN NUMBER := FND_API.G_MISS_NUM,
                               P_ORIG_PROJECT_ID              IN NUMBER,
                               P_PROJECT_NAME                 IN VARCHAR2,
                               P_PROJECT_NUMBER               IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_DESCRIPTION                  IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_PROJECT_TYPE                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_PROJECT_STATUS_CODE          IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_PROJECT_STATUS_NAME          IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_DISTRIBUTION_RULE            IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_PUBLIC_SECTOR_FLAG           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_CARRYING_OUT_ORGANIZATION_ID IN NUMBER := FND_API.G_MISS_NUM,
                               P_ORGANIZATION_NAME            IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_START_DATE                   IN DATE := FND_API.G_MISS_DATE,
                               P_COMPLETION_DATE              IN DATE := FND_API.G_MISS_DATE,
                               P_PROBABILITY_MEMBER_ID        IN NUMBER := FND_API.G_MISS_NUM,
                               P_PROBABILITY_PERCENTAGE       IN NUMBER := FND_API.G_MISS_NUM,
                               P_PROJECT_VALUE                IN NUMBER := FND_API.G_MISS_NUM,
                               P_EXPECTED_APPROVAL_DATE       IN DATE := FND_API.G_MISS_DATE,
                               P_TEAM_TEMPLATE_ID             IN NUMBER := FND_API.G_MISS_NUM,
                               P_TEAM_TEMPLATE_NAME           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_COUNTRY_CODE                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_COUNTRY_NAME                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_REGION                       IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_CITY                         IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_CUSTOMER_ID                  IN NUMBER := FND_API.G_MISS_NUM,
                               P_CUSTOMER_NAME                IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_AGREEMENT_CURRENCY           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_AGREEMENT_CURRENCY_NAME      IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_AGREEMENT_AMOUNT             IN NUMBER := FND_API.G_MISS_NUM,
                               P_AGREEMENT_ORG_ID             IN NUMBER := FND_API.G_MISS_NUM,
                               P_AGREEMENT_ORG_NAME           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_OPP_VALUE_CURRENCY_CODE      IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_OPP_VALUE_CURRENCY_NAME      IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_PRIORITY_CODE                IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_TEMPLATE_FLAG                IN VARCHAR2 := 'N',
                               P_COPY_TASK_FLAG               IN VARCHAR2 := 'Y', --added by ouzhiwei at 2012-05-30
                               P_SECURITY_LEVEL               IN NUMBER := FND_API.G_MISS_NUM,
                               /*Customer Account Relationships*/
                               P_BILL_TO_CUSTOMER_ID IN NUMBER := NULL,
                               P_SHIP_TO_CUSTOMER_ID IN NUMBER := NULL,
                               /*Customer Account Relationships*/
                               P_BILL_TO_CUSTOMER_NAME IN VARCHAR2 := NULL, /* Bug2977891*/
                               P_SHIP_TO_CUSTOMER_NAME IN VARCHAR2 := NULL, /* Bug2977891*/
                               -- anlee
                               -- Project Long Name changes
                               P_LONG_NAME IN VARCHAR2 DEFAULT NULL,
                               -- end of changes
                               P_PROJECT_ID         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                               P_NEW_PROJECT_NUMBER OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               X_RETURN_STATUS      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               X_MSG_COUNT          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                               X_MSG_DATA           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END XXPA_PROJ_PUBLIC_PVT;
/
CREATE OR REPLACE PACKAGE BODY XXPA_PROJ_PUBLIC_PVT IS
  /* $Header: cuxpapub.pls 120.3 2012-02-06 16:10:20 Siman ship $ */

  /*=================================================================
   Copyright (C) HAND Enterprise Solutions Co.,Ltd.                               
                AllRights Reserved   
    =================================================================
  * =================================================================
  *   PROGRAM NAME:
  *                xxpa_proj_public_pvt
  *   DESCRIPTION:
  *                PA:Project,Top Task,Task,Customer,Contact,Agreements API 
  *   HISTORY:
  *     1.00  2012-01-11   Hand       Created
  *
  * ===============================================================*/
  L_DEBUG                VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),
                                            'N');
  G_PROGRAM_PROCESS_UNIT VARCHAR2(1000);
  G_PKG_NAME             VARCHAR2(30) := 'XXPA_PROJ_PUBLIC_PVT';
  --log
  PROCEDURE LOG(P_CONTENT IN VARCHAR2) IS
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, P_CONTENT);
  END LOG;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  UPDATE_PROJ_KEY_MEMBER
  *
  *   DESCRIPTION: Check Customer is validate 
  *
  *   ARGUMENT:   p_project_id      Project ID 
  *               p_effective_date  Key member Start Date          
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 2012-02-06 Siman.he
  *                     Creation Description
  * =============================================*/

  PROCEDURE UPDATE_PROJ_KEY_MEMBER(P_PROJECT_ID     IN NUMBER,
                                   P_EFFECTIVE_DATE IN DATE,
                                   X_RETURN_STATUS  OUT VARCHAR2,
                                   X_MSG_COUNT      OUT NUMBER,
                                   X_MSG_DATA       OUT VARCHAR2) IS
    L_WF_TYPE               VARCHAR2(250);
    L_WF_ITEM_TYPE          VARCHAR2(250);
    L_WF_PROCESS            VARCHAR2(250);
    L_PROJECT_PARTY_ID      NUMBER;
    L_ASSIGNMENT_ID         NUMBER;
    L_RECORD_VERSION_NUMBER NUMBER;
    L_ROLE_TYPE_ID          NUMBER;
    CURSOR CUR_REC IS
      SELECT PPP.PROJECT_PARTY_ID,
             PPP.PROJECT_ROLE_TYPE,
             PPP.PERSON_ID,
             PPP.RECORD_VERSION_NUMBER,
             PPP.END_DATE_ACTIVE
        FROM PA_PROJECT_PLAYERS PPP
       WHERE SYSDATE BETWEEN PPP.START_DATE_ACTIVE AND
             NVL(PPP.END_DATE_ACTIVE, SYSDATE + 1) --Added by Huaijun.Yan 2012/03/23
         AND PPP.PROJECT_ID = P_PROJECT_ID;
    L_INDEX NUMBER;
    L_DATA  VARCHAR2(1000);
  BEGIN
  
    /*SAVEPOINT key_member;*/
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT     := 0;
    X_MSG_DATA      := NULL;
    
    FOR REC IN CUR_REC LOOP
      L_PROJECT_PARTY_ID := REC.PROJECT_PARTY_ID;
      PA_PROJECT_PARTIES_PUB.UPDATE_PROJECT_PARTY(P_API_VERSION           => 1.0,
                                                  P_INIT_MSG_LIST         => NULL,
                                                  P_COMMIT                => NULL,
                                                  P_VALIDATE_ONLY         => NULL,
                                                  P_VALIDATION_LEVEL      => 100,
                                                  P_DEBUG_MODE            => 'N',
                                                  P_OBJECT_ID             => P_PROJECT_ID,
                                                  P_OBJECT_TYPE           => 'PA_PROJECTS',
                                                  P_PROJECT_ROLE_ID       => L_ROLE_TYPE_ID,
                                                  P_PROJECT_ROLE_TYPE     => REC.PROJECT_ROLE_TYPE,
                                                  P_RESOURCE_TYPE_ID      => 101,
                                                  P_RESOURCE_SOURCE_ID    => REC.PERSON_ID,
                                                  P_RESOURCE_NAME         => NULL,
                                                  P_RESOURCE_ID           => NULL,
                                                  P_START_DATE_ACTIVE     => TRUNC(P_EFFECTIVE_DATE),
                                                  P_SCHEDULED_FLAG        => 'N',
                                                  P_RECORD_VERSION_NUMBER => REC.RECORD_VERSION_NUMBER,
                                                  P_CALLING_MODULE        => 'FORM',
                                                  P_PROJECT_ID            => P_PROJECT_ID,
                                                  P_PROJECT_END_DATE      => NULL,
                                                  P_END_DATE_ACTIVE       => REC.END_DATE_ACTIVE,
                                                  P_PROJECT_PARTY_ID      => REC.PROJECT_PARTY_ID,
                                                  X_WF_TYPE               => L_WF_TYPE,
                                                  X_WF_ITEM_TYPE          => L_WF_ITEM_TYPE,
                                                  X_WF_PROCESS            => L_WF_PROCESS,
                                                  X_ASSIGNMENT_ID         => L_ASSIGNMENT_ID,
                                                  X_RETURN_STATUS         => X_RETURN_STATUS,
                                                  X_MSG_COUNT             => X_MSG_COUNT,
                                                  X_MSG_DATA              => X_MSG_DATA);
    
      FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
        PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                            P_MSG_INDEX     => I,
                                            P_MSG_COUNT     => X_MSG_COUNT,
                                            P_MSG_DATA      => X_MSG_DATA,
                                            P_DATA          => L_DATA,
                                            P_MSG_INDEX_OUT => L_INDEX);
        X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 255);
      END LOOP;
      IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        EXIT;
      END IF;
    END LOOP;
  
    /*  IF x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO SAVEPOINT key_member;
    END IF;*/
  EXCEPTION
    WHEN OTHERS THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_COUNT     := 1;
      X_MSG_DATA      := 'Calling pa_project_parties_pub.update_project_party Error ! Argument project_party_id =' ||
                         L_PROJECT_PARTY_ID;
      /*ROLLBACK TO SAVEPOINT key_member;*/
  END;

  /*==================================================
  Program Name:
      create_proj_manager
  Description:
      create project key member project_manager
  History:
      1.00  2012/2/29 0:31:17  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE CREATE_PROJ_MANAGER(P_PROJECT_ID     IN NUMBER,
                                P_EMPLOYEE_ID    IN NUMBER,
                                P_EFFECTIVE_DATE IN DATE,
                                P_DEBUG_MODE     IN VARCHAR2,
                                X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
                                X_MSG_COUNT      OUT NOCOPY NUMBER,
                                X_MSG_DATA       OUT NOCOPY VARCHAR2) IS
    L_API_NAME       CONSTANT VARCHAR2(30) := 'create_proj_manager';
    L_SAVEPOINT_NAME CONSTANT VARCHAR2(30) := '';
    L_PROJECT_ROLE_ID  PA_PROJECT_ROLE_TYPES_B.PROJECT_ROLE_ID%TYPE;
    X_PROJECT_PARTY_ID NUMBER;
    X_RESOURCE_ID      NUMBER;
    X_ASSIGNMENT_ID    NUMBER;
    X_WF_TYPE          VARCHAR2(240);
    X_WF_ITEM_TYPE     VARCHAR2(240);
    X_WF_PROCESS       VARCHAR2(240);
    L_END_DATE_ACTIVE  DATE;
    L_INDEX            NUMBER;
    L_DATA             VARCHAR2(1000);
  BEGIN
    LOG('begin create proj manager ');
    /*  SAVEPOINT l_savepoint_name;*/
    LOG('process 10');
    SELECT PRT.PROJECT_ROLE_ID
      INTO L_PROJECT_ROLE_ID
      FROM PA.PA_PROJECT_ROLE_TYPES_B PRT
     WHERE PRT.PROJECT_ROLE_TYPE = 'PROJECT MANAGER';
    LOG('process 20');
    PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(P_VALIDATE_ONLY => FND_API.G_FALSE,
                                                /* p_validation_level   => NULL,*/
                                                P_DEBUG_MODE         => P_DEBUG_MODE,
                                                P_OBJECT_ID          => P_PROJECT_ID,
                                                P_OBJECT_TYPE        => 'PA_PROJECTS',
                                                P_PROJECT_ROLE_ID    => L_PROJECT_ROLE_ID,
                                                P_PROJECT_ROLE_TYPE  => 'PROJECT MANAGER',
                                                P_RESOURCE_SOURCE_ID => P_EMPLOYEE_ID, --from HR_EMPLOYEES 
                                                P_START_DATE_ACTIVE  => P_EFFECTIVE_DATE,
                                                P_CALLING_MODULE     => NULL,
                                                P_END_DATE_ACTIVE    => L_END_DATE_ACTIVE,
                                                P_PROJECT_ID         => P_PROJECT_ID,
                                                X_PROJECT_PARTY_ID   => X_PROJECT_PARTY_ID,
                                                X_RESOURCE_ID        => X_RESOURCE_ID,
                                                X_ASSIGNMENT_ID      => X_ASSIGNMENT_ID,
                                                X_WF_TYPE            => X_WF_TYPE,
                                                X_WF_ITEM_TYPE       => X_WF_ITEM_TYPE,
                                                X_WF_PROCESS         => X_WF_PROCESS,
                                                X_RETURN_STATUS      => X_RETURN_STATUS,
                                                X_MSG_COUNT          => X_MSG_COUNT,
                                                X_MSG_DATA           => X_MSG_DATA);
    FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
      PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                          P_MSG_INDEX     => I,
                                          P_MSG_COUNT     => X_MSG_COUNT,
                                          P_MSG_DATA      => X_MSG_DATA,
                                          P_DATA          => L_DATA,
                                          P_MSG_INDEX_OUT => L_INDEX);
      X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 255);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_COUNT     := 1;
      X_MSG_DATA      := 'Calling pa_project_parties_pub.create_project_party Error ! ' ||
                         SQLERRM;
      LOG(X_MSG_DATA);
      /*   log('ROLLBACK TO SAVEPOINT :'||l_savepoint_name);                   
      ROLLBACK TO SAVEPOINT l_savepoint_name;
      log('rollback complete');*/
  END CREATE_PROJ_MANAGER;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  CHECK_CUSTOMER_VALID
  *
  *   DESCRIPTION: Check Customer is validate 
  *
  *   ARGUMENT:   
  *                         
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 2012-02-06 Siman.he
  *                     Creation Description
  * =============================================*/
  FUNCTION CHECK_CUST_ADDR_VALID(P_CUST_ACCT_SITE_ID IN NUMBER,
                                 P_SITE_USE_CODE     IN VARCHAR2)
    RETURN VARCHAR2 IS
    L_VALID_FLAG VARCHAR2(1);
  BEGIN
    SELECT 'Y'
      INTO L_VALID_FLAG
      FROM HZ_CUST_SITE_USES_ALL HCS
     WHERE HCS.CUST_ACCT_SITE_ID = P_CUST_ACCT_SITE_ID
       AND HCS.STATUS = 'A'
       AND HCS.SITE_USE_CODE = P_SITE_USE_CODE;
    RETURN L_VALID_FLAG;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  CHECK_CUSTOMER_VALID
  *
  *   DESCRIPTION: Check Customer is validate 
  *
  *   ARGUMENT:   
  *                         
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 2012-02-06 Siman.he
  *                     Creation Description
  * =============================================*/
  FUNCTION CHECK_CUSTOMER_VALID(P_CUSTOMER_ID IN NUMBER) RETURN VARCHAR2 IS
    L_VALID_FLAG VARCHAR2(1);
  BEGIN
    SELECT 'Y'
      INTO L_VALID_FLAG
      FROM HZ_CUST_ACCOUNTS HCA
     WHERE HCA.CUST_ACCOUNT_ID = P_CUSTOMER_ID
       AND HCA.STATUS = 'A';
    RETURN L_VALID_FLAG;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  CHECK_AGREEMENT_FUNDINGS_PROJ
  *
  *   DESCRIPTION: Check Agreement Fundings Project Valid
  *
  *   ARGUMENT:   
  *                         
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 2012-02-06 Siman.he
  *                     Creation Description
  * =============================================*/
  FUNCTION CHECK_AGREEMENT_FUNDINGS_PROJ(P_AGREEMENT_ID          IN NUMBER,
                                         P_PROJECT_ID            IN NUMBER,
                                         X_INVPROC_CURRENCY_TYPE OUT VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
  
    SELECT PPV.INVPROC_CURRENCY_TYPE
      INTO X_INVPROC_CURRENCY_TYPE
      FROM PA_PROJ_FUND_VALID_V PPV, PA_AGREEMENTS_ALL PAA
     WHERE PAA.AGREEMENT_ID = P_AGREEMENT_ID
       AND PPV.PROJECT_ID = P_PROJECT_ID
       AND PPV.CUSTOMER_ID = PAA.CUSTOMER_ID
       AND PPV.ORG_ID = PAA.ORG_ID
       AND PPV.CC_PRVDR_FLAG = 'N'
       AND (PPV.MULTI_CURRENCY_BILLING_FLAG = 'Y' OR
           (PPV.MULTI_CURRENCY_BILLING_FLAG = 'N' AND
           PPV.PROJFUNC_CURRENCY_CODE = PAA.AGREEMENT_CURRENCY_CODE))
       AND NVL(PPV.TEMPLATE_FLAG, 'N') = 'N'
       AND NOT EXISTS
     (SELECT NULL
              FROM PA_SUMMARY_PROJECT_FUNDINGS SPF
             WHERE SPF.PROJECT_ID = PPV.PROJECT_ID
               AND PPV.INVPROC_CURRENCY_TYPE = 'FUNDING_CURRENCY'
               AND SPF.FUNDING_CURRENCY_CODE <> PAA.AGREEMENT_CURRENCY_CODE
               AND (SPF.TOTAL_BASELINED_AMOUNT <> 0 OR
                   SPF.TOTAL_UNBASELINED_AMOUNT <> 0 OR
                   SPF.TOTAL_ACCRUED_AMOUNT <> 0 OR
                   SPF.TOTAL_BILLED_AMOUNT <> 0))
       AND NOT EXISTS
     (SELECT NULL
              FROM PA_PROJECTS_ALL     P,
                   PA_AGREEMENTS_ALL   A,
                   PA_PROJECT_FUNDINGS F
             WHERE P.PROJECT_ID = PPV.PROJECT_ID
               AND P.PROJECT_ID = F.PROJECT_ID
               AND F.AGREEMENT_ID = A.AGREEMENT_ID
               AND P.TEMPLATE_FLAG = 'Y'
               AND A.TEMPLATE_FLAG = 'Y'
               AND (A.AGREEMENT_NUM <> PAA.AGREEMENT_NUM OR
                   A.AGREEMENT_TYPE <> PAA.AGREEMENT_TYPE));
    RETURN 'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'N';
    WHEN OTHERS THEN
      RETURN 'E'; -- Error    
  END;

  PROCEDURE CREATE_PROJECT_PVT(P_COMMIT                       IN VARCHAR2 := FND_API.G_FALSE,
                               P_VALIDATE_ONLY                IN VARCHAR2 := FND_API.G_TRUE,
                               P_VALIDATION_LEVEL             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                               P_CALLING_MODULE               IN VARCHAR2 := 'SELF_SERVICE',
                               P_DEBUG_MODE                   IN VARCHAR2 := 'N',
                               P_MAX_MSG_COUNT                IN NUMBER := FND_API.G_MISS_NUM,
                               P_ORIG_PROJECT_ID              IN NUMBER,
                               P_PROJECT_NAME                 IN VARCHAR2,
                               P_PROJECT_NUMBER               IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_DESCRIPTION                  IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_PROJECT_TYPE                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_PROJECT_STATUS_CODE          IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_DISTRIBUTION_RULE            IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_PUBLIC_SECTOR_FLAG           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_CARRYING_OUT_ORGANIZATION_ID IN NUMBER := FND_API.G_MISS_NUM,
                               P_START_DATE                   IN DATE := FND_API.G_MISS_DATE,
                               P_COMPLETION_DATE              IN DATE := FND_API.G_MISS_DATE,
                               P_PROBABILITY_MEMBER_ID        IN NUMBER := FND_API.G_MISS_NUM,
                               P_PROJECT_VALUE                IN NUMBER := FND_API.G_MISS_NUM,
                               P_EXPECTED_APPROVAL_DATE       IN DATE := FND_API.G_MISS_DATE,
                               P_TEAM_TEMPLATE_ID             IN NUMBER := FND_API.G_MISS_NUM,
                               P_COUNTRY_CODE                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_REGION                       IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_CITY                         IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_CUSTOMER_ID                  IN NUMBER := FND_API.G_MISS_NUM,
                               P_AGREEMENT_CURRENCY           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_AGREEMENT_AMOUNT             IN NUMBER := FND_API.G_MISS_NUM,
                               P_AGREEMENT_ORG_ID             IN NUMBER := FND_API.G_MISS_NUM,
                               P_OPP_VALUE_CURRENCY_CODE      IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_PRIORITY_CODE                IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_TEMPLATE_FLAG                IN VARCHAR2 := 'N',
                               P_COPY_TASK_FLAG               IN VARCHAR2 := 'Y', --added by ouzhiwei at 2012-05-30
                               P_SECURITY_LEVEL               IN NUMBER := FND_API.G_MISS_NUM,
                               -- Customer Account Relationship
                               P_BILL_TO_CUSTOMER_ID IN NUMBER := NULL, /* For Bug 2731449 */
                               P_SHIP_TO_CUSTOMER_ID IN NUMBER := NULL, /* For Bug 2731449 */
                               --Customer Account Relationship
                               -- anlee
                               -- Project Long Name changes
                               P_LONG_NAME IN VARCHAR2 DEFAULT NULL,
                               -- end of changes
                               P_PROJECT_ID         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                               P_NEW_PROJECT_NUMBER OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               X_RETURN_STATUS      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               X_MSG_COUNT          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                               X_MSG_DATA           OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
   IS
  
    -- 4363092 TCA changes, replaced RA views with HZ tables
    --l_customer_id              ra_customers.customer_id%TYPE;
    L_CUSTOMER_ID HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE;
    -- 4363092 end
  
    L_ORGANIZATION_ID         HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE;
    L_PROJECT_STATUS_CODE     PA_PROJECT_STATUSES.PROJECT_STATUS_CODE%TYPE;
    L_PROJECT_ID              PA_PROJECTS.PROJECT_ID%TYPE;
    L_PROJECT_NUMBER_OUT      PA_PROJECTS.SEGMENT1%TYPE;
    L_PROBABILITY_MEMBER_ID   PA_PROBABILITY_MEMBERS.PROBABILITY_MEMBER_ID%TYPE;
    L_PROJECT_VALUE           PA_PROJECTS_ALL.PROJECT_VALUE%TYPE;
    L_EXPECTED_APPROVAL_DATE  PA_PROJECTS_ALL.EXPECTED_APPROVAL_DATE%TYPE;
    L_COMPLETION_DATE         PA_PROJECTS_ALL.COMPLETION_DATE%TYPE;
    L_PUBLIC_SECTOR_FLAG      PA_PROJECTS_ALL.PUBLIC_SECTOR_FLAG%TYPE;
    L_DESCRIPTION             PA_PROJECTS_ALL.DESCRIPTION%TYPE;
    L_PROJECT_NUMBER          PA_PROJECTS_ALL.SEGMENT1%TYPE;
    L_DISTRIBUTION_RULE       PA_PROJECTS_ALL.DISTRIBUTION_RULE%TYPE;
    L_TEAM_TEMPLATE_ID        PA_TEAM_TEMPLATES.TEAM_TEMPLATE_ID%TYPE;
    L_COUNTRY_CODE            PA_LOCATIONS.COUNTRY_CODE%TYPE;
    L_REGION                  PA_LOCATIONS.REGION%TYPE;
    L_CITY                    PA_LOCATIONS.CITY%TYPE;
    L_RETURN_STATUS           VARCHAR2(1);
    L_ERROR_MSG_CODE          VARCHAR2(250);
    L_MSG_COUNT               NUMBER;
    L_MSG_DATA                VARCHAR2(250);
    L_ERR_CODE                VARCHAR2(250);
    L_ERR_STAGE               VARCHAR2(2000);
    L_ERR_STACK               VARCHAR2(2000);
    L_DATA                    VARCHAR2(250);
    L_MSG_INDEX_OUT           NUMBER;
    L_RELATIONSHIP_TYPE       VARCHAR2(30);
    L_AGREEMENT_CURRENCY      FND_CURRENCIES_VL.CURRENCY_CODE%TYPE;
    L_AGREEMENT_AMOUNT        NUMBER;
    L_AGREEMENT_ORG_ID        NUMBER;
    L_OPP_VALUE_CURRENCY_CODE FND_CURRENCIES_VL.CURRENCY_CODE%TYPE;
    L_PRIORITY_CODE           VARCHAR2(30);
    -- Added the nvl condition in the cursor query for bug 4954698
    CURSOR L_OVERRIDE_FIELDS_CSR --(c_project_id NUMBER) Bug 5478390: c_project_id no longer used
    IS
      SELECT TYPE
        FROM PA_OVERRIDE_FIELDS_V POF
       WHERE POF.PA_FIELD_NAME = 'CUSTOMER_NAME'
         AND EXISTS
       (SELECT 'x'
                FROM PA_PROJECTS_ALL PP
              -- replaced c_project_id with p_orig_project_id in where clause for Bug 5478390
               WHERE PP.PROJECT_ID = P_ORIG_PROJECT_ID
                 AND NVL(PP.CREATED_FROM_PROJECT_ID, P_ORIG_PROJECT_ID) =
                     POF.PA_SOURCE_TEMPLATE_ID);
  
    -- anlee
    -- added for copy retention
    -- Modified below cursor for bug 5724556
    CURSOR L_GET_PROJECT_DATES_CSR(C_PROJECT_ID NUMBER) IS
      SELECT START_DATE, COMPLETION_DATE, ENABLE_TOP_TASK_CUSTOMER_FLAG
        FROM PA_PROJECTS_ALL
       WHERE PROJECT_ID = C_PROJECT_ID;
  
    L_PROJ_START_DATE      DATE;
    L_PROJ_COMPLETION_DATE DATE;
  
    /* Bug2450468 Begin */
  
    L_PROJECT_TYPE_CLASS_CODE VARCHAR2(80);
  
    CURSOR L_GET_PRJ_CLASS_CODE IS
      SELECT MEANING
        FROM PA_PROJECT_TYPES PT, PA_LOOKUPS LPS, PA_PROJECTS PP
       WHERE PT.PROJECT_TYPE = PP.PROJECT_TYPE
         AND LPS.LOOKUP_TYPE(+) = 'PROJECT TYPE CLASS'
         AND LPS.LOOKUP_CODE(+) = PT.PROJECT_TYPE_CLASS_CODE
         AND PP.PROJECT_ID = P_ORIG_PROJECT_ID;
  
    /* Bug2450468 End */
    -- bug 5724556
    L_CALLING_CONTEXT    VARCHAR2(25);
    L_TOP_TASK_CUST_FLAG VARCHAR2(1) := 'N';
  
  BEGIN
  
    -- Standard call to check for call compatibility
  
    IF (P_DEBUG_MODE = 'Y') THEN
      PA_DEBUG.DEBUG('Create_Project PVT: Checking the api version number.');
    END IF;
  
    --dbms_output.put_line('Starts here PA_PROJECTS_MAINT_PVT.CREATE_PROJECT  ... ');
  
    IF P_COMMIT = FND_API.G_TRUE THEN
      SAVEPOINT PRM_CREATE_PROJECT;
    END IF;
  
    X_RETURN_STATUS := 'S';
  
    --dbms_output.put_line('Before p_carrying_out_organization_id  ... ');
  
    --dbms_output.put_line('Before copy_project call  ... ');
  
    IF (NOT FND_API.TO_BOOLEAN(P_VALIDATE_ONLY)) THEN
    
      IF (P_DEBUG_MODE = 'Y') THEN
        PA_DEBUG.DEBUG('Create_Project PVT: Calling copy project');
      END IF;
    
      IF P_PROJECT_VALUE = FND_API.G_MISS_NUM THEN
        L_PROJECT_VALUE := NULL;
      ELSE
        L_PROJECT_VALUE := P_PROJECT_VALUE;
      END IF;
    
      IF P_EXPECTED_APPROVAL_DATE = FND_API.G_MISS_DATE THEN
        L_EXPECTED_APPROVAL_DATE := NULL;
      ELSE
        L_EXPECTED_APPROVAL_DATE := P_EXPECTED_APPROVAL_DATE;
      END IF;
    
      IF P_COMPLETION_DATE = FND_API.G_MISS_DATE THEN
        L_COMPLETION_DATE := NULL;
      ELSE
        L_COMPLETION_DATE := P_COMPLETION_DATE;
      END IF;
    
      IF P_PUBLIC_SECTOR_FLAG = FND_API.G_MISS_CHAR THEN
        L_PUBLIC_SECTOR_FLAG := NULL;
      ELSE
        L_PUBLIC_SECTOR_FLAG := P_PUBLIC_SECTOR_FLAG;
      END IF;
    
      IF P_DISTRIBUTION_RULE = FND_API.G_MISS_CHAR THEN
        L_DISTRIBUTION_RULE := NULL;
      ELSE
        L_DISTRIBUTION_RULE := P_DISTRIBUTION_RULE;
      END IF;
    
      IF P_DESCRIPTION = FND_API.G_MISS_CHAR THEN
        L_DESCRIPTION := NULL;
      ELSE
        L_DESCRIPTION := P_DESCRIPTION;
      END IF;
    
      IF P_PROJECT_NUMBER = FND_API.G_MISS_CHAR THEN
        L_PROJECT_NUMBER := NULL;
      ELSE
        L_PROJECT_NUMBER := P_PROJECT_NUMBER;
      END IF;
    
      IF P_TEAM_TEMPLATE_ID = FND_API.G_MISS_NUM THEN
        L_TEAM_TEMPLATE_ID := NULL;
      ELSE
        L_TEAM_TEMPLATE_ID := P_TEAM_TEMPLATE_ID;
      END IF;
    
      IF P_COUNTRY_CODE = FND_API.G_MISS_CHAR THEN
        L_COUNTRY_CODE := NULL;
      ELSE
        L_COUNTRY_CODE := P_COUNTRY_CODE;
      END IF;
    
      IF P_REGION = FND_API.G_MISS_CHAR THEN
        L_REGION := NULL;
      ELSE
        L_REGION := P_REGION;
      END IF;
    
      IF P_CITY = FND_API.G_MISS_CHAR THEN
        L_CITY := NULL;
      ELSE
        L_CITY := P_CITY;
      END IF;
    
      IF P_AGREEMENT_CURRENCY = FND_API.G_MISS_CHAR THEN
        L_AGREEMENT_CURRENCY := NULL;
      ELSE
        L_AGREEMENT_CURRENCY := P_AGREEMENT_CURRENCY;
      END IF;
    
      IF P_AGREEMENT_AMOUNT = FND_API.G_MISS_NUM THEN
        L_AGREEMENT_AMOUNT := NULL;
      ELSE
        L_AGREEMENT_AMOUNT := P_AGREEMENT_AMOUNT;
      END IF;
    
      IF P_AGREEMENT_ORG_ID = FND_API.G_MISS_NUM THEN
        L_AGREEMENT_ORG_ID := NULL;
      ELSE
        L_AGREEMENT_ORG_ID := P_AGREEMENT_ORG_ID;
      END IF;
    
      IF P_OPP_VALUE_CURRENCY_CODE = FND_API.G_MISS_CHAR THEN
        L_OPP_VALUE_CURRENCY_CODE := NULL;
      ELSE
        L_OPP_VALUE_CURRENCY_CODE := P_OPP_VALUE_CURRENCY_CODE;
      END IF;
    
      --Priority code changes
      IF P_PRIORITY_CODE = FND_API.G_MISS_CHAR THEN
        L_PRIORITY_CODE := NULL;
      ELSE
        L_PRIORITY_CODE := P_PRIORITY_CODE;
      END IF;
    
      IF (P_PROJECT_VALUE IS NOT NULL AND P_PROJECT_VALUE < 0) THEN
        PA_UTILS.ADD_MESSAGE(P_APP_SHORT_NAME => 'PA',
                             P_MSG_NAME       => 'PA_BU_NEED_POS_NUM');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    
      --dbms_output.put_line('Before UPDATE PA_PROJECTS_ALL Status : ');
    
      PA_PROJECT_CORE1.COPY_PROJECT(X_ORIG_PROJECT_ID        => P_ORIG_PROJECT_ID,
                                    X_PROJECT_NAME           => RTRIM(P_PROJECT_NAME),
                                    X_PROJECT_NUMBER         => RTRIM(L_PROJECT_NUMBER),
                                    X_DESCRIPTION            => RTRIM(L_DESCRIPTION),
                                    X_PROJECT_TYPE           => NULL --project_type is always defaulted from template
                                   ,
                                    X_PROJECT_STATUS_CODE    => P_PROJECT_STATUS_CODE,
                                    X_DISTRIBUTION_RULE      => L_DISTRIBUTION_RULE,
                                    X_PUBLIC_SECTOR_FLAG     => L_PUBLIC_SECTOR_FLAG,
                                    X_ORGANIZATION_ID        => P_CARRYING_OUT_ORGANIZATION_ID,
                                    X_START_DATE             => P_START_DATE,
                                    X_COMPLETION_DATE        => L_COMPLETION_DATE,
                                    X_PROBABILITY_MEMBER_ID  => P_PROBABILITY_MEMBER_ID,
                                    X_PROJECT_VALUE          => L_PROJECT_VALUE,
                                    X_EXPECTED_APPROVAL_DATE => L_EXPECTED_APPROVAL_DATE
                                    --begin update by ouzhiwei at 2012-05-30
                                    --in PA_PROJECTS_MAINT_PVT.CREATE_PROJECT is hard coding as 'Y'
                                    --set x_copy_task_flag as parameter for others program call
                                    --old
                                    /*,x_copy_task_flag               => 'Y' */
                                    --new
                                   ,
                                    X_COPY_TASK_FLAG => P_COPY_TASK_FLAG
                                    --end
                                   ,
                                    X_COPY_BUDGET_FLAG        => 'Y',
                                    X_USE_OVERRIDE_FLAG       => 'Y',
                                    X_COPY_ASSIGNMENT_FLAG    => 'N',
                                    X_TEMPLATE_FLAG           => P_TEMPLATE_FLAG,
                                    X_PROJECT_ID              => L_PROJECT_ID,
                                    X_ERR_CODE                => L_ERR_CODE,
                                    X_ERR_STAGE               => L_ERR_STAGE,
                                    X_ERR_STACK               => L_ERR_STACK,
                                    X_NEW_PROJECT_NUMBER      => L_PROJECT_NUMBER_OUT,
                                    X_TEAM_TEMPLATE_ID        => L_TEAM_TEMPLATE_ID,
                                    X_COUNTRY_CODE            => L_COUNTRY_CODE,
                                    X_REGION                  => L_REGION,
                                    X_CITY                    => L_CITY,
                                    X_OPP_VALUE_CURRENCY_CODE => L_OPP_VALUE_CURRENCY_CODE,
                                    X_AGREEMENT_CURRENCY      => L_AGREEMENT_CURRENCY,
                                    X_AGREEMENT_AMOUNT        => L_AGREEMENT_AMOUNT,
                                    X_AGREEMENT_ORG_ID        => L_AGREEMENT_ORG_ID,
                                    X_ORG_PROJECT_COPY_FLAG   => 'N',
                                    X_PRIORITY_CODE           => L_PRIORITY_CODE,
                                    X_SECURITY_LEVEL          => P_SECURITY_LEVEL
                                    -- anlee
                                    -- Project Long Name changes
                                   ,
                                    X_LONG_NAME => P_LONG_NAME
                                    -- End of changes
                                    --maansari   for bug 2783257
                                   ,
                                    X_CUSTOMER_ID => P_CUSTOMER_ID
                                    --End of changes.
                                    );
    
      IF (P_DEBUG_MODE = 'Y') THEN
        PA_DEBUG.DEBUG('Create_Project PVT: Checking error messages returned from copy project');
      END IF;
      IF L_ERR_CODE > 0 THEN
        IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          /*            IF NOT pa_project_pvt.check_valid_message(l_err_stage)
          THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                     p_msg_name      => 'PA_PROJ_COPY_PROJECT_FAILED');
          
               x_msg_data := 'PA_PROJ_COPY_PROJECT_FAILED';
           ELSE*/
          /* Bug2450468 Begin - Commenting the following code and adding the code*/
          /*     IF l_err_stage IS NOT NULL
                THEN
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                  p_msg_name       => l_err_stage);
                END IF;
          */
        
          IF L_ERR_STAGE = 'PA_INVALID_PT_CLASS_ORG' THEN
            OPEN L_GET_PRJ_CLASS_CODE;
            FETCH L_GET_PRJ_CLASS_CODE
              INTO L_PROJECT_TYPE_CLASS_CODE;
            CLOSE L_GET_PRJ_CLASS_CODE;
          
            PA_UTILS.ADD_MESSAGE(P_APP_SHORT_NAME => 'PA',
                                 P_MSG_NAME       => 'PA_INVALID_PT_CLASS_ORG',
                                 P_TOKEN1         => 'PT_CLASS',
                                 P_VALUE1         => L_PROJECT_TYPE_CLASS_CODE);
          ELSE
            IF L_ERR_STAGE IS NOT NULL THEN
              PA_UTILS.ADD_MESSAGE(P_APP_SHORT_NAME => 'PA',
                                   P_MSG_NAME       => L_ERR_STAGE);
            END IF;
          
          END IF; -- l_err_stage = 'PA_INVALID_PT_CLASS_ORG'
          /* Bug2450468 End */
        
          X_MSG_DATA := L_ERR_STAGE;
          --             END IF;
        
        END IF;
      
        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      
      ELSIF L_ERR_CODE < 0 THEN
        /*  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                PA_UTILS.ADD_MESSAGE
                  (p_app_short_name => 'PA',
                   p_msg_name       => 'PA_PROJ_COPY_PROJECT_FAILED');
                x_msg_data := 'PA_PROJ_COPY_PROJECT_FAILED';
        END IF;*/
        IF L_ERR_STAGE IS NOT NULL THEN
          PA_UTILS.ADD_MESSAGE(P_APP_SHORT_NAME => 'PA',
                               P_MSG_NAME       => L_ERR_STAGE);
        END IF;
        X_MSG_DATA      := L_ERR_STAGE;
        X_RETURN_STATUS := 'E';
      END IF;
    
      P_PROJECT_ID         := L_PROJECT_ID;
      P_NEW_PROJECT_NUMBER := L_PROJECT_NUMBER_OUT;
    
    END IF; -- p_validate_only = 'Y'
  
    L_MSG_COUNT := FND_MSG_PUB.COUNT_MSG;
  
    --dbms_output.put_line('MSG_COUNT : CREATE_PROJECT ERROR : '||to_char(l_msg_count));
  
    IF L_MSG_COUNT > 0 THEN
      X_RETURN_STATUS := 'E';
      X_MSG_COUNT     := L_MSG_COUNT;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  
    --dbms_output.put_line('*** Before create_customer call *** '||to_char(p_customer_id));
  
    -- added below code for bug 5724556
    OPEN L_GET_PROJECT_DATES_CSR(L_PROJECT_ID);
    FETCH L_GET_PROJECT_DATES_CSR
      INTO L_PROJ_START_DATE, L_PROJ_COMPLETION_DATE, L_TOP_TASK_CUST_FLAG;
    CLOSE L_GET_PROJECT_DATES_CSR;
  
    IF NVL(L_TOP_TASK_CUST_FLAG, 'N') = 'Y' THEN
      L_CALLING_CONTEXT := 'CREATE_PROJ_TT_CUST';
    ELSE
      L_CALLING_CONTEXT := 'CREATE_PROJ_NO_TT_CUST';
    END IF;
  
    IF P_CUSTOMER_ID IS NOT NULL THEN
    
      --dbms_output.put_line('*** Before create_customer call  ... '||to_char(l_project_id));
    
      OPEN L_OVERRIDE_FIELDS_CSR; --(p_project_id)Bug 5478390: p_project_id no longer required.
      FETCH L_OVERRIDE_FIELDS_CSR
        INTO L_RELATIONSHIP_TYPE;
      CLOSE L_OVERRIDE_FIELDS_CSR;
    
      --dbms_output.put_line('*** Relationship  ... '||l_relationship_type);
      -- l_relationship_type := 'Primary';
    
      IF (P_DEBUG_MODE = 'Y') THEN
        PA_DEBUG.DEBUG('Create_Project PVT: Calling create customer private API');
      END IF;
      PA_PROJECTS_MAINT_PVT.CREATE_CUSTOMER(P_COMMIT            => FND_API.G_FALSE,
                                            P_VALIDATE_ONLY     => P_VALIDATE_ONLY,
                                            P_VALIDATION_LEVEL  => P_VALIDATION_LEVEL,
                                            P_DEBUG_MODE        => P_DEBUG_MODE,
                                            P_MAX_MSG_COUNT     => FND_API.G_MISS_NUM,
                                            P_CALLING_MODULE    => L_CALLING_CONTEXT, -- bug 5724556
                                            P_PROJECT_ID        => L_PROJECT_ID,
                                            P_CUSTOMER_ID       => P_CUSTOMER_ID,
                                            P_RELATIONSHIP_TYPE => L_RELATIONSHIP_TYPE,
                                            --Customer Account relationship
                                            P_BILL_TO_CUSTOMER_ID => P_BILL_TO_CUSTOMER_ID,
                                            P_SHIP_TO_CUSTOMER_ID => P_SHIP_TO_CUSTOMER_ID,
                                            --Customer Account relationship
                                            X_RETURN_STATUS => L_RETURN_STATUS,
                                            X_MSG_COUNT     => L_MSG_COUNT,
                                            X_MSG_DATA      => L_MSG_DATA);
    
      --dbms_output.put_line('IN create_customer call  ... '||l_return_status);
    
    END IF;
  
    L_MSG_COUNT := FND_MSG_PUB.COUNT_MSG;
  
    --dbms_output.put_line('After create_customer call  ... '||to_char(l_msg_count));
  
    IF L_MSG_COUNT > 0 THEN
      --      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      X_MSG_COUNT := L_MSG_COUNT;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  
    -- anlee
    -- Copy rentention
    IF (NOT FND_API.TO_BOOLEAN(P_VALIDATE_ONLY)) THEN
      IF (P_DEBUG_MODE = 'Y') THEN
        PA_DEBUG.DEBUG('Create_Project PVT: Calling copy retention API');
      END IF;
    
      /* Moved this code to before call to create customer to get enable top task customer flag
         bug 5690529
      OPEN l_get_project_dates_csr(l_project_id);
      FETCH l_get_project_dates_csr INTO l_proj_start_date, l_proj_completion_date;
      CLOSE l_get_project_dates_csr;
      */
      PA_RETENTION_UTIL.COPY_RETENTION_SETUP(P_FR_PROJECT_ID => P_ORIG_PROJECT_ID,
                                             P_TO_PROJECT_ID => L_PROJECT_ID,
                                             P_FR_DATE       => L_PROJ_START_DATE,
                                             P_TO_DATE       => L_PROJ_COMPLETION_DATE,
                                             X_RETURN_STATUS => L_RETURN_STATUS,
                                             X_MSG_COUNT     => L_MSG_COUNT,
                                             X_MSG_DATA      => L_MSG_DATA);
    
      L_MSG_COUNT := FND_MSG_PUB.COUNT_MSG;
    
      IF L_MSG_COUNT > 0 THEN
        X_MSG_COUNT := L_MSG_COUNT;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    
    END IF;
  
    IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
      COMMIT WORK;
    END IF;
  
  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF P_COMMIT = FND_API.G_TRUE THEN
        ROLLBACK TO PRM_CREATE_PROJECT;
      END IF;
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG(P_PKG_NAME       => G_PKG_NAME,
                              P_PROCEDURE_NAME => 'CREATE_PROJECT_PVT',
                              P_ERROR_TEXT     => SUBSTRB(SQLERRM, 1, 240));
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
    
    WHEN FND_API.G_EXC_ERROR THEN
      IF P_COMMIT = FND_API.G_TRUE THEN
        ROLLBACK TO PRM_CREATE_PROJECT;
      END IF;
      X_RETURN_STATUS := 'E';
    
    WHEN OTHERS THEN
      IF P_COMMIT = FND_API.G_TRUE THEN
        ROLLBACK TO PRM_CREATE_PROJECT;
      END IF;
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG(P_PKG_NAME       => G_PKG_NAME,
                              P_PROCEDURE_NAME => 'CREATE_PROJECT_PVT',
                              P_ERROR_TEXT     => SUBSTRB(SQLERRM, 1, 240));
      RAISE;
    
  END CREATE_PROJECT_PVT;

  PROCEDURE CREATE_PROJECT_PUB(P_API_VERSION                  IN NUMBER := 1.0,
                               P_INIT_MSG_LIST                IN VARCHAR2 := FND_API.G_TRUE,
                               P_COMMIT                       IN VARCHAR2 := FND_API.G_FALSE,
                               P_VALIDATE_ONLY                IN VARCHAR2 := FND_API.G_TRUE,
                               P_VALIDATION_LEVEL             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                               P_CALLING_MODULE               IN VARCHAR2 := 'SELF_SERVICE',
                               P_DEBUG_MODE                   IN VARCHAR2 := 'N',
                               P_MAX_MSG_COUNT                IN NUMBER := FND_API.G_MISS_NUM,
                               P_ORIG_PROJECT_ID              IN NUMBER,
                               P_PROJECT_NAME                 IN VARCHAR2,
                               P_PROJECT_NUMBER               IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_DESCRIPTION                  IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_PROJECT_TYPE                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_PROJECT_STATUS_CODE          IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_PROJECT_STATUS_NAME          IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_DISTRIBUTION_RULE            IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_PUBLIC_SECTOR_FLAG           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_CARRYING_OUT_ORGANIZATION_ID IN NUMBER := FND_API.G_MISS_NUM,
                               P_ORGANIZATION_NAME            IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_START_DATE                   IN DATE := FND_API.G_MISS_DATE,
                               P_COMPLETION_DATE              IN DATE := FND_API.G_MISS_DATE,
                               P_PROBABILITY_MEMBER_ID        IN NUMBER := FND_API.G_MISS_NUM,
                               P_PROBABILITY_PERCENTAGE       IN NUMBER := FND_API.G_MISS_NUM,
                               P_PROJECT_VALUE                IN NUMBER := FND_API.G_MISS_NUM,
                               P_EXPECTED_APPROVAL_DATE       IN DATE := FND_API.G_MISS_DATE,
                               P_TEAM_TEMPLATE_ID             IN NUMBER := FND_API.G_MISS_NUM,
                               P_TEAM_TEMPLATE_NAME           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_COUNTRY_CODE                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_COUNTRY_NAME                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_REGION                       IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_CITY                         IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_CUSTOMER_ID                  IN NUMBER := FND_API.G_MISS_NUM,
                               P_CUSTOMER_NAME                IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_AGREEMENT_CURRENCY           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_AGREEMENT_CURRENCY_NAME      IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_AGREEMENT_AMOUNT             IN NUMBER := FND_API.G_MISS_NUM,
                               P_AGREEMENT_ORG_ID             IN NUMBER := FND_API.G_MISS_NUM,
                               P_AGREEMENT_ORG_NAME           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_OPP_VALUE_CURRENCY_CODE      IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_OPP_VALUE_CURRENCY_NAME      IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_PRIORITY_CODE                IN VARCHAR2 := FND_API.G_MISS_CHAR,
                               P_TEMPLATE_FLAG                IN VARCHAR2 := 'N',
                               P_COPY_TASK_FLAG               IN VARCHAR2 := 'Y', --added by ouzhiwei at 2012-05-30
                               P_SECURITY_LEVEL               IN NUMBER := FND_API.G_MISS_NUM,
                               /*Customer Account Relationships*/
                               P_BILL_TO_CUSTOMER_ID IN NUMBER := NULL,
                               P_SHIP_TO_CUSTOMER_ID IN NUMBER := NULL,
                               /*Customer Account Relationships*/
                               P_BILL_TO_CUSTOMER_NAME IN VARCHAR2 := NULL, /* Bug2977891*/
                               P_SHIP_TO_CUSTOMER_NAME IN VARCHAR2 := NULL, /* Bug2977891*/
                               -- anlee
                               -- Project Long Name changes
                               P_LONG_NAME IN VARCHAR2 DEFAULT NULL,
                               -- end of changes
                               P_PROJECT_ID         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                               P_NEW_PROJECT_NUMBER OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               X_RETURN_STATUS      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               X_MSG_COUNT          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                               X_MSG_DATA           OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
   IS
  
    L_API_NAME    CONSTANT VARCHAR(30) := 'create_project_pub';
    L_API_VERSION CONSTANT NUMBER := 1.0;
  
    -- 4363092 TCA changes, replaced RA views with HZ tables
    /*
    l_customer_id              ra_customers.customer_id%TYPE;
    l_bill_to_customer_id      ra_customers.customer_id%TYPE; -- Bug 2977891
    l_ship_to_customer_id      ra_customers.customer_id%TYPE; -- Bug 2977891
    */
  
    L_CUSTOMER_ID         HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE;
    L_BILL_TO_CUSTOMER_ID HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE; -- Bug 2977891
    L_SHIP_TO_CUSTOMER_ID HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE; -- Bug 2977891
    -- 4363092 end
  
    L_ORGANIZATION_ID         HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE;
    L_PROJECT_STATUS_CODE     PA_PROJECT_STATUSES.PROJECT_STATUS_CODE%TYPE;
    L_PROJECT_ID              PA_PROJECTS.PROJECT_ID%TYPE;
    L_PROJECT_TYPE            PA_PROJECTS_ALL.PROJECT_TYPE%TYPE;
    L_PROJECT_NUMBER_OUT      PA_PROJECTS.SEGMENT1%TYPE;
    L_PROBABILITY_MEMBER_ID   PA_PROBABILITY_MEMBERS.PROBABILITY_MEMBER_ID%TYPE;
    L_TEAM_TEMPLATE_ID        PA_TEAM_TEMPLATES.TEAM_TEMPLATE_ID%TYPE;
    L_COUNTRY_CODE            PA_LOCATIONS.COUNTRY_CODE%TYPE;
    L_RETURN_STATUS           VARCHAR2(1);
    L_ERROR_MSG_CODE          VARCHAR2(250);
    L_MSG_COUNT               NUMBER;
    L_MSG_DATA                VARCHAR2(2000);
    L_ERR_CODE                VARCHAR2(2000);
    L_ERR_STAGE               VARCHAR2(2000);
    L_ERR_STACK               VARCHAR2(2000);
    L_DATA                    VARCHAR2(2000);
    L_MSG_INDEX_OUT           NUMBER;
    L_RELATIONSHIP_TYPE       VARCHAR2(30);
    L_NEW_PROJECT_NUMBER      VARCHAR2(30);
    L_AGREEMENT_CURRENCY      FND_CURRENCIES_VL.CURRENCY_CODE%TYPE;
    L_AGREEMENT_ORG_ID        PA_ORGANIZATIONS_PROJECT_V.ORGANIZATION_ID%TYPE;
    L_OPP_VALUE_CURRENCY_CODE FND_CURRENCIES_VL.CURRENCY_CODE%TYPE;
  
    CURSOR L_PROJECT_CSR(C_PROJECT_ID NUMBER) IS
      SELECT PROJECT_TYPE
        FROM PA_PROJECTS_ALL
       WHERE PROJECT_ID = C_PROJECT_ID;
  
  BEGIN
  
    -- Standard call to check for call compatibility
  
    IF (P_DEBUG_MODE = 'Y') THEN
      PA_DEBUG.DEBUG('Create_Project PUB : Checking the api version number.');
    END IF;
  
    --dbms_output.put_line('Starts here PA_PROJECTS_MAINT_PUB.CREATE_PROJECT  ... ');
  
    IF P_COMMIT = FND_API.G_TRUE THEN
      SAVEPOINT PRM_CREATE_PROJECT;
    END IF;
  
    --dbms_output.put_line('Before FND_API.COMPATIBLE_API_CALL  ... ');
  
    IF NOT FND_API.COMPATIBLE_API_CALL(L_API_VERSION,
                                       P_API_VERSION,
                                       L_API_NAME,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  
    -- Initialize the message stack if required
  
    IF (P_DEBUG_MODE = 'Y') THEN
      PA_DEBUG.DEBUG('CREATE_PROJECT PUB : Initializing message stack.');
    END IF;
  
    PA_DEBUG.INIT_ERR_STACK('XXPA_PROJ_PUBLIC_PVT.CREATE_PROJECT_PUB');
  
    IF FND_API.TO_BOOLEAN(NVL(P_INIT_MSG_LIST, FND_API.G_FALSE)) THEN
      FND_MSG_PUB.INITIALIZE;
    END IF;
  
    --  dbms_output.put_line('After initializing the stack');
  
    X_RETURN_STATUS := 'S';
  
    --dbms_output.put_line('Before p_carrying_out_organization_id  ... ');
  
    IF (P_CARRYING_OUT_ORGANIZATION_ID IS NOT NULL AND
       P_CARRYING_OUT_ORGANIZATION_ID <> FND_API.G_MISS_NUM) OR
       (P_ORGANIZATION_NAME IS NOT NULL AND
       P_ORGANIZATION_NAME <> FND_API.G_MISS_CHAR) THEN
      IF (P_DEBUG_MODE = 'Y') THEN
        PA_DEBUG.DEBUG('Create_Project PUB : Checking Carrying out organization');
      END IF;
      PA_HR_ORG_UTILS.CHECK_ORGNAME_OR_ID(P_ORGANIZATION_ID   => P_CARRYING_OUT_ORGANIZATION_ID,
                                          P_ORGANIZATION_NAME => P_ORGANIZATION_NAME,
                                          P_CHECK_ID_FLAG     => 'A',
                                          X_ORGANIZATION_ID   => L_ORGANIZATION_ID,
                                          X_RETURN_STATUS     => L_RETURN_STATUS,
                                          X_ERROR_MSG_CODE    => L_ERROR_MSG_CODE);
    
      --dbms_output.put_line('AFTER check org  ... '||l_return_status);
    
      IF L_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
        PA_UTILS.ADD_MESSAGE(P_APP_SHORT_NAME => 'PA',
                             P_MSG_NAME       => L_ERROR_MSG_CODE);
      
        X_MSG_DATA      := L_ERROR_MSG_CODE;
        X_RETURN_STATUS := 'E';
      END IF;
    
    END IF;
  
    --dbms_output.put_line('Before p_project_status_code  ... ');
  
    IF (P_PROJECT_STATUS_CODE IS NOT NULL AND
       P_PROJECT_STATUS_CODE <> FND_API.G_MISS_CHAR) OR
       (P_PROJECT_STATUS_NAME IS NOT NULL AND
       P_PROJECT_STATUS_NAME <> FND_API.G_MISS_CHAR) THEN
    
      --dbms_output.put_line('IN p_project_status_code  ... ');
    
      IF (P_DEBUG_MODE = 'Y') THEN
        PA_DEBUG.DEBUG('Create_Project PUB : Checking Project status');
      END IF;
    
      PA_PROJECTS_MAINT_UTILS.CHECK_PROJECT_STATUS_OR_ID(P_PROJECT_STATUS_CODE => P_PROJECT_STATUS_CODE,
                                                         P_PROJECT_STATUS_NAME => P_PROJECT_STATUS_NAME,
                                                         P_CHECK_ID_FLAG       => 'A',
                                                         X_PROJECT_STATUS_CODE => L_PROJECT_STATUS_CODE,
                                                         X_RETURN_STATUS       => L_RETURN_STATUS,
                                                         X_ERROR_MSG_CODE      => L_ERROR_MSG_CODE);
      --dbms_output.put_line('AFTER check project status  ... '||l_return_status);
      IF L_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
        PA_UTILS.ADD_MESSAGE(P_APP_SHORT_NAME => 'PA',
                             P_MSG_NAME       => L_ERROR_MSG_CODE);
        X_MSG_DATA      := L_ERROR_MSG_CODE;
        X_RETURN_STATUS := 'E';
      END IF;
    END IF;
  
    --dbms_output.put_line('Before probability member call  ... ');
  
    OPEN L_PROJECT_CSR(P_PROJECT_ID);
    FETCH L_PROJECT_CSR
      INTO L_PROJECT_TYPE;
    CLOSE L_PROJECT_CSR;
  
    L_PROBABILITY_MEMBER_ID := P_PROBABILITY_MEMBER_ID;
  
    IF (P_PROBABILITY_MEMBER_ID IS NOT NULL AND
       P_PROBABILITY_MEMBER_ID <> FND_API.G_MISS_NUM) OR
       (P_PROBABILITY_PERCENTAGE IS NOT NULL AND
       P_PROBABILITY_PERCENTAGE <> FND_API.G_MISS_NUM) THEN
      IF (P_DEBUG_MODE = 'Y') THEN
        PA_DEBUG.DEBUG('Create_Project PUB : Checking Probability code');
      END IF;
      PA_PROJECTS_MAINT_UTILS.CHECK_PROBABILITY_CODE_OR_ID(P_PROBABILITY_MEMBER_ID  => P_PROBABILITY_MEMBER_ID,
                                                           P_PROBABILITY_PERCENTAGE => P_PROBABILITY_PERCENTAGE,
                                                           P_PROJECT_TYPE           => L_PROJECT_TYPE,
                                                           P_CHECK_ID_FLAG          => 'Y',
                                                           X_PROBABILITY_MEMBER_ID  => L_PROBABILITY_MEMBER_ID,
                                                           X_RETURN_STATUS          => L_RETURN_STATUS,
                                                           X_ERROR_MSG_CODE         => L_ERROR_MSG_CODE);
    
      --dbms_output.put_line('AFTER check probablity  ... '||l_return_status);
    
      IF L_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
        PA_UTILS.ADD_MESSAGE(P_APP_SHORT_NAME => 'PA',
                             P_MSG_NAME       => L_ERROR_MSG_CODE);
        X_MSG_DATA      := L_ERROR_MSG_CODE;
        X_RETURN_STATUS := 'E';
      END IF;
    END IF;
  
    --dbms_output.put_line('Before customer call  ...'||to_char(p_customer_id));
  
    L_CUSTOMER_ID := P_CUSTOMER_ID; --bug 2783257
  
    IF (P_CUSTOMER_ID IS NOT NULL AND P_CUSTOMER_ID <> FND_API.G_MISS_NUM) OR
       (P_CUSTOMER_NAME IS NOT NULL AND
       P_CUSTOMER_NAME <> FND_API.G_MISS_CHAR) THEN
      IF (P_DEBUG_MODE = 'Y') THEN
        PA_DEBUG.DEBUG('Create_Project PUB : Checking Customer code');
      END IF;
      --dbms_output.put_line('Before check customer or customer call  ... ');
      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID(P_CUSTOMER_ID    => P_CUSTOMER_ID,
                                                            P_CUSTOMER_NAME  => P_CUSTOMER_NAME,
                                                            P_CHECK_ID_FLAG  => 'A',
                                                            X_CUSTOMER_ID    => L_CUSTOMER_ID,
                                                            X_RETURN_STATUS  => L_RETURN_STATUS,
                                                            X_ERROR_MSG_CODE => L_ERROR_MSG_CODE);
    
      --dbms_output.put_line('AFTER check customer or customer call  ... '||l_return_status);
      IF L_RETURN_STATUS <> 'S' THEN
        PA_UTILS.ADD_MESSAGE(P_APP_SHORT_NAME => 'PA',
                             P_MSG_NAME       => L_ERROR_MSG_CODE);
        X_MSG_DATA      := L_ERROR_MSG_CODE;
        X_RETURN_STATUS := 'E';
      END IF;
    
    END IF;
  
    /* Bug2977891 Begin*/
    L_BILL_TO_CUSTOMER_ID := P_BILL_TO_CUSTOMER_ID;
    IF (P_BILL_TO_CUSTOMER_ID IS NOT NULL AND
       P_BILL_TO_CUSTOMER_ID <> FND_API.G_MISS_NUM) OR
       (P_BILL_TO_CUSTOMER_NAME IS NOT NULL AND
       P_BILL_TO_CUSTOMER_NAME <> FND_API.G_MISS_CHAR) THEN
      IF (P_DEBUG_MODE = 'Y') THEN
        PA_DEBUG.DEBUG('Create_Project PUB : Checking Bill Customer');
      END IF;
    
      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID(P_CUSTOMER_ID    => P_BILL_TO_CUSTOMER_ID,
                                                            P_CUSTOMER_NAME  => P_BILL_TO_CUSTOMER_NAME,
                                                            P_CHECK_ID_FLAG  => 'A',
                                                            X_CUSTOMER_ID    => L_BILL_TO_CUSTOMER_ID,
                                                            X_RETURN_STATUS  => L_RETURN_STATUS,
                                                            X_ERROR_MSG_CODE => L_ERROR_MSG_CODE);
    
      IF L_RETURN_STATUS <> 'S' THEN
        PA_UTILS.ADD_MESSAGE(P_APP_SHORT_NAME => 'PA',
                             P_MSG_NAME       => L_ERROR_MSG_CODE || '_BILL');
        X_MSG_DATA      := L_ERROR_MSG_CODE;
        X_RETURN_STATUS := 'E';
      END IF;
    
    END IF;
  
    L_SHIP_TO_CUSTOMER_ID := P_SHIP_TO_CUSTOMER_ID;
    IF (P_SHIP_TO_CUSTOMER_ID IS NOT NULL AND
       P_SHIP_TO_CUSTOMER_ID <> FND_API.G_MISS_NUM) OR
       (P_SHIP_TO_CUSTOMER_NAME IS NOT NULL AND
       P_SHIP_TO_CUSTOMER_NAME <> FND_API.G_MISS_CHAR) THEN
      IF (P_DEBUG_MODE = 'Y') THEN
        PA_DEBUG.DEBUG('Create_Project PUB : Checking Ship Customer');
      END IF;
    
      PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID(P_CUSTOMER_ID    => P_SHIP_TO_CUSTOMER_ID,
                                                            P_CUSTOMER_NAME  => P_SHIP_TO_CUSTOMER_NAME,
                                                            P_CHECK_ID_FLAG  => 'A',
                                                            X_CUSTOMER_ID    => L_SHIP_TO_CUSTOMER_ID,
                                                            X_RETURN_STATUS  => L_RETURN_STATUS,
                                                            X_ERROR_MSG_CODE => L_ERROR_MSG_CODE);
    
      IF L_RETURN_STATUS <> 'S' THEN
        PA_UTILS.ADD_MESSAGE(P_APP_SHORT_NAME => 'PA',
                             P_MSG_NAME       => L_ERROR_MSG_CODE || '_SHIP');
        X_MSG_DATA      := L_ERROR_MSG_CODE;
        X_RETURN_STATUS := 'E';
      END IF;
    
    END IF;
    /* Bug2977891 End*/
  
    --dbms_output.put_line('Before check team template call  ... ');
    IF (P_TEAM_TEMPLATE_ID IS NOT NULL AND
       P_TEAM_TEMPLATE_ID <> FND_API.G_MISS_NUM) OR
       (P_TEAM_TEMPLATE_NAME IS NOT NULL AND
       P_TEAM_TEMPLATE_NAME <> FND_API.G_MISS_CHAR) THEN
      IF (P_DEBUG_MODE = 'Y') THEN
        PA_DEBUG.DEBUG('Create_Project PUB : Checking team template ID');
      END IF;
    
      PA_TEAM_TEMPLATES_UTILS.CHECK_TEAM_TEMPLATE_NAME_OR_ID(P_TEAM_TEMPLATE_ID   => P_TEAM_TEMPLATE_ID,
                                                             P_TEAM_TEMPLATE_NAME => P_TEAM_TEMPLATE_NAME,
                                                             P_CHECK_ID_FLAG      => 'A',
                                                             X_TEAM_TEMPLATE_ID   => L_TEAM_TEMPLATE_ID,
                                                             X_RETURN_STATUS      => L_RETURN_STATUS,
                                                             X_ERROR_MESSAGE_CODE => L_ERROR_MSG_CODE);
    
      IF L_RETURN_STATUS <> 'S' THEN
        PA_UTILS.ADD_MESSAGE(P_APP_SHORT_NAME => 'PA',
                             P_MSG_NAME       => L_ERROR_MSG_CODE);
        X_MSG_DATA      := L_ERROR_MSG_CODE;
        X_RETURN_STATUS := 'E';
      END IF;
    END IF;
  
    --dbms_output.put_line('Before check country code call  ... ');
    IF (P_COUNTRY_CODE IS NOT NULL AND
       P_COUNTRY_CODE <> FND_API.G_MISS_CHAR) OR
       (P_COUNTRY_NAME IS NOT NULL AND
       P_COUNTRY_NAME <> FND_API.G_MISS_CHAR) THEN
      IF (P_DEBUG_MODE = 'Y') THEN
        PA_DEBUG.DEBUG('Create_Project PUB : Checking country code');
      END IF;
    
      PA_LOCATION_UTILS.CHECK_COUNTRY_NAME_OR_CODE(P_COUNTRY_CODE       => P_COUNTRY_CODE,
                                                   P_COUNTRY_NAME       => P_COUNTRY_NAME,
                                                   P_CHECK_ID_FLAG      => 'A',
                                                   X_COUNTRY_CODE       => L_COUNTRY_CODE,
                                                   X_RETURN_STATUS      => L_RETURN_STATUS,
                                                   X_ERROR_MESSAGE_CODE => L_ERROR_MSG_CODE);
    
      IF L_RETURN_STATUS <> 'S' THEN
        PA_UTILS.ADD_MESSAGE(P_APP_SHORT_NAME => 'PA',
                             P_MSG_NAME       => L_ERROR_MSG_CODE);
        X_MSG_DATA      := L_ERROR_MSG_CODE;
        X_RETURN_STATUS := 'E';
      END IF;
    END IF;
  
    --dbms_output.put_line('Before check agreement currency call  ... ');
    IF (P_AGREEMENT_CURRENCY IS NOT NULL AND
       P_AGREEMENT_CURRENCY <> FND_API.G_MISS_CHAR) OR
       (P_AGREEMENT_CURRENCY_NAME IS NOT NULL AND
       P_AGREEMENT_CURRENCY_NAME <> FND_API.G_MISS_CHAR) THEN
      IF (P_DEBUG_MODE = 'Y') THEN
        PA_DEBUG.DEBUG('Create_Project PUB : Checking agreement currency');
      END IF;
    
      PA_PROJECTS_MAINT_UTILS.CHECK_CURRENCY_NAME_OR_CODE(P_AGREEMENT_CURRENCY      => P_AGREEMENT_CURRENCY,
                                                          P_AGREEMENT_CURRENCY_NAME => P_AGREEMENT_CURRENCY_NAME,
                                                          P_CHECK_ID_FLAG           => 'Y',
                                                          X_AGREEMENT_CURRENCY      => L_AGREEMENT_CURRENCY,
                                                          X_RETURN_STATUS           => L_RETURN_STATUS,
                                                          X_ERROR_MSG_CODE          => L_ERROR_MSG_CODE);
    
      IF L_RETURN_STATUS <> 'S' THEN
        PA_UTILS.ADD_MESSAGE(P_APP_SHORT_NAME => 'PA',
                             P_MSG_NAME       => L_ERROR_MSG_CODE);
        X_MSG_DATA      := L_ERROR_MSG_CODE;
        X_RETURN_STATUS := 'E';
      END IF;
    END IF;
  
    IF (P_OPP_VALUE_CURRENCY_CODE IS NOT NULL AND
       P_OPP_VALUE_CURRENCY_CODE <> FND_API.G_MISS_CHAR) OR
       (P_OPP_VALUE_CURRENCY_NAME IS NOT NULL AND
       P_OPP_VALUE_CURRENCY_NAME <> FND_API.G_MISS_CHAR) THEN
      IF (P_DEBUG_MODE = 'Y') THEN
        PA_DEBUG.DEBUG('Create_Project PUB : Checking Opportunity Value currency');
      END IF;
    
      PA_PROJECTS_MAINT_UTILS.CHECK_CURRENCY_NAME_OR_CODE(P_AGREEMENT_CURRENCY      => P_OPP_VALUE_CURRENCY_CODE,
                                                          P_AGREEMENT_CURRENCY_NAME => P_OPP_VALUE_CURRENCY_NAME,
                                                          P_CHECK_ID_FLAG           => 'Y',
                                                          X_AGREEMENT_CURRENCY      => L_OPP_VALUE_CURRENCY_CODE,
                                                          X_RETURN_STATUS           => L_RETURN_STATUS,
                                                          X_ERROR_MSG_CODE          => L_ERROR_MSG_CODE);
    
      IF L_RETURN_STATUS <> 'S' THEN
        PA_UTILS.ADD_MESSAGE(P_APP_SHORT_NAME => 'PA',
                             P_MSG_NAME       => L_ERROR_MSG_CODE);
        X_MSG_DATA      := L_ERROR_MSG_CODE;
        X_RETURN_STATUS := 'E';
      END IF;
    END IF;
  
    --dbms_output.put_line('Before check agreement org call  ... ');
    IF (P_AGREEMENT_ORG_ID IS NOT NULL AND
       P_AGREEMENT_ORG_ID <> FND_API.G_MISS_NUM) OR
       (P_AGREEMENT_ORG_NAME IS NOT NULL AND
       P_AGREEMENT_ORG_NAME <> FND_API.G_MISS_CHAR) THEN
      IF (P_DEBUG_MODE = 'Y') THEN
        PA_DEBUG.DEBUG('Create_Project PUB : Checking agreement org');
      END IF;
    
      PA_PROJECTS_MAINT_UTILS.CHECK_AGREEMENT_ORG_NAME_OR_ID(P_AGREEMENT_ORG_ID   => P_AGREEMENT_ORG_ID,
                                                             P_AGREEMENT_ORG_NAME => P_AGREEMENT_ORG_NAME,
                                                             P_CHECK_ID_FLAG      => 'Y',
                                                             X_AGREEMENT_ORG_ID   => L_AGREEMENT_ORG_ID,
                                                             X_RETURN_STATUS      => L_RETURN_STATUS,
                                                             X_ERROR_MSG_CODE     => L_ERROR_MSG_CODE);
    
      IF L_RETURN_STATUS <> 'S' THEN
        PA_UTILS.ADD_MESSAGE(P_APP_SHORT_NAME => 'PA',
                             P_MSG_NAME       => L_ERROR_MSG_CODE);
        X_MSG_DATA      := L_ERROR_MSG_CODE;
        X_RETURN_STATUS := 'E';
      END IF;
    END IF;
  
    IF (P_DEBUG_MODE = 'Y') THEN
      PA_DEBUG.DEBUG('Create_Project PUB : checking message count');
    END IF;
  
    L_MSG_COUNT := FND_MSG_PUB.COUNT_MSG;
    IF L_MSG_COUNT > 0 THEN
      X_MSG_COUNT := L_MSG_COUNT;
      IF L_MSG_COUNT = 1 THEN
        PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => FND_API.G_TRUE,
                                            P_MSG_INDEX     => 1,
                                            P_MSG_COUNT     => L_MSG_COUNT,
                                            P_MSG_DATA      => L_MSG_DATA,
                                            P_DATA          => L_DATA,
                                            P_MSG_INDEX_OUT => L_MSG_INDEX_OUT);
        X_MSG_DATA := L_DATA;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  
    /*
       IF l_msg_count = 1 THEN
           x_msg_count := l_msg_count;
           x_msg_data := FND_MSG_PUB.get(p_msg_index => 1,
                                         p_encoded   => FND_API.G_TRUE);
       ELSE
          x_msg_count  := l_msg_count;
       END IF;
       if l_msg_count > 0 THEN
          x_return_status := 'E';
          RAISE  FND_API.G_EXC_ERROR;
       end if;
    */
  
    --dbms_output.put_line('Starts here PA_PROJECTS_MAINT_PVT.CREATE_PROJECT  ... ');
  
    /* For Bug 2731449 modified p_bill_to_customer_id to l_bill_to_customer_id
    and p_ship_to_customer_id to l_ship_to_customer_id */
  
    IF (P_DEBUG_MODE = 'Y') THEN
      PA_DEBUG.DEBUG('Create_Project PUB : Calling private api Create_project');
    END IF;
  
    /*PA_PROJECTS_MAINT_PVT.CREATE_PROJECT*/
    CREATE_PROJECT_PVT(P_COMMIT                       => FND_API.G_FALSE,
                       P_VALIDATE_ONLY                => P_VALIDATE_ONLY,
                       P_VALIDATION_LEVEL             => P_VALIDATION_LEVEL,
                       P_CALLING_MODULE               => P_CALLING_MODULE,
                       P_DEBUG_MODE                   => P_DEBUG_MODE,
                       P_MAX_MSG_COUNT                => P_MAX_MSG_COUNT,
                       P_ORIG_PROJECT_ID              => P_ORIG_PROJECT_ID,
                       P_PROJECT_NAME                 => P_PROJECT_NAME,
                       P_PROJECT_NUMBER               => P_PROJECT_NUMBER,
                       P_DESCRIPTION                  => P_DESCRIPTION,
                       P_PROJECT_TYPE                 => P_PROJECT_TYPE,
                       P_PROJECT_STATUS_CODE          => L_PROJECT_STATUS_CODE,
                       P_DISTRIBUTION_RULE            => P_DISTRIBUTION_RULE,
                       P_PUBLIC_SECTOR_FLAG           => P_PUBLIC_SECTOR_FLAG,
                       P_CARRYING_OUT_ORGANIZATION_ID => L_ORGANIZATION_ID,
                       P_START_DATE                   => P_START_DATE,
                       P_COMPLETION_DATE              => P_COMPLETION_DATE,
                       P_PROBABILITY_MEMBER_ID        => P_PROBABILITY_MEMBER_ID,
                       P_PROJECT_VALUE                => P_PROJECT_VALUE,
                       P_EXPECTED_APPROVAL_DATE       => P_EXPECTED_APPROVAL_DATE,
                       P_TEAM_TEMPLATE_ID             => L_TEAM_TEMPLATE_ID,
                       P_COUNTRY_CODE                 => L_COUNTRY_CODE,
                       P_REGION                       => P_REGION,
                       P_CITY                         => P_CITY,
                       P_CUSTOMER_ID                  => L_CUSTOMER_ID,
                       P_AGREEMENT_CURRENCY           => L_AGREEMENT_CURRENCY,
                       P_AGREEMENT_AMOUNT             => P_AGREEMENT_AMOUNT,
                       P_AGREEMENT_ORG_ID             => L_AGREEMENT_ORG_ID,
                       P_OPP_VALUE_CURRENCY_CODE      => L_OPP_VALUE_CURRENCY_CODE,
                       P_COPY_TASK_FLAG               => P_COPY_TASK_FLAG,
                       P_PRIORITY_CODE                => P_PRIORITY_CODE,
                       P_TEMPLATE_FLAG                => P_TEMPLATE_FLAG,
                       P_SECURITY_LEVEL               => P_SECURITY_LEVEL,
                       --Customer Account Relationship Changes
                       P_BILL_TO_CUSTOMER_ID => L_BILL_TO_CUSTOMER_ID, /* For Bug 2731449 */
                       P_SHIP_TO_CUSTOMER_ID => L_SHIP_TO_CUSTOMER_ID, /* For Bug 2731449 */
                       --Customer Account Relationship Changes
                       -- anlee
                       -- Project Long Name changes
                       P_LONG_NAME => P_LONG_NAME,
                       -- End of changes
                       P_PROJECT_ID         => L_PROJECT_ID,
                       P_NEW_PROJECT_NUMBER => L_NEW_PROJECT_NUMBER,
                       X_RETURN_STATUS      => L_RETURN_STATUS,
                       X_MSG_COUNT          => L_MSG_COUNT,
                       X_MSG_DATA           => L_MSG_DATA);
  
    IF (P_DEBUG_MODE = 'Y') THEN
      PA_DEBUG.DEBUG('Create_Project PUB : checking message count');
    END IF;
    --dbms_output.put_line('After PRIVATE API call  ... '||l_return_status);
  
    L_MSG_COUNT := FND_MSG_PUB.COUNT_MSG;
    IF L_MSG_COUNT > 0 THEN
      X_MSG_COUNT := L_MSG_COUNT;
      IF L_MSG_COUNT = 1 THEN
        PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => FND_API.G_TRUE,
                                            P_MSG_INDEX     => 1,
                                            P_MSG_COUNT     => L_MSG_COUNT,
                                            P_MSG_DATA      => L_MSG_DATA,
                                            P_DATA          => L_DATA,
                                            P_MSG_INDEX_OUT => L_MSG_INDEX_OUT);
        X_MSG_DATA := L_DATA;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    /*
       l_msg_count := FND_MSG_PUB.count_msg;
    
       IF l_msg_count = 1 THEN
           x_msg_data := FND_MSG_PUB.get(p_msg_index => 1,
                                          p_encoded   => FND_API.G_TRUE);
           x_msg_count := l_msg_count;
       ELSE
          x_msg_count  := l_msg_count;
       END IF;
    
       IF l_msg_count > 0 THEN
          x_return_status := 'E';
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    */
    P_PROJECT_ID         := L_PROJECT_ID;
    P_NEW_PROJECT_NUMBER := L_NEW_PROJECT_NUMBER;
    X_RETURN_STATUS      := 'S';
  
    --dbms_output.put_line('Created ProjectID in PUBLIC API : '||to_char(l_project_id)||l_new_project_number);
  
    IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
      COMMIT WORK;
    END IF;
  
  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF P_COMMIT = FND_API.G_TRUE THEN
        ROLLBACK TO PRM_CREATE_PROJECT;
      END IF;
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG(P_PKG_NAME       => G_PKG_NAME,
                              P_PROCEDURE_NAME => 'CREATE_PROJECT_PUB',
                              P_ERROR_TEXT     => SUBSTRB(SQLERRM, 1, 240));
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
    
    WHEN FND_API.G_EXC_ERROR THEN
      IF P_COMMIT = FND_API.G_TRUE THEN
        ROLLBACK TO PRM_CREATE_PROJECT;
      END IF;
      X_RETURN_STATUS := 'E';
    
    WHEN OTHERS THEN
      IF P_COMMIT = FND_API.G_TRUE THEN
        ROLLBACK TO PRM_CREATE_PROJECT;
      END IF;
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG(P_PKG_NAME       => G_PKG_NAME,
                              P_PROCEDURE_NAME => 'CREATE_PROJECT_PUB',
                              P_ERROR_TEXT     => SUBSTRB(SQLERRM, 1, 240));
      RAISE;
    
  END CREATE_PROJECT_PUB;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  ADD_PROJECT
  *
  *   DESCRIPTION: Create an new Project from Copy a PA:project's Template
  *
  *   ARGUMENT:   p_orig_project_id     Source Project Id 
  *               p_long_name           Project's Long name   
  *               p_description         Project's Description     
  *               p_effective_date      Project's Start Date 
  *               p_debug_flag          Debug Flag 
  *   RETURN:
  *               x_new_project_number Project Number
  *               x_project_id         Project ID
  *               x_return_status      API Process Status
  *   HISTORY:
  *     1.00 2012-02-06 Siman.he
  *                     Creation Description
  * =============================================*/
  PROCEDURE ADD_PROJECT(P_ORIG_PROJECT_ID    IN NUMBER,
                        P_PROJ_NUM           IN VARCHAR2,
                        P_PROJECT_NAME       IN VARCHAR2 := FND_API.G_MISS_CHAR,
                        P_LONG_NAME          IN VARCHAR2,
                        P_DESCRIPTION        IN VARCHAR2,
                        P_EFFECTIVE_DATE     IN DATE,
                        P_START_DATE         IN DATE := FND_API.G_MISS_DATE,
                        P_COMPLETION_DATE    IN DATE := FND_API.G_MISS_DATE,
                        P_COPY_TASK_FLAG     IN VARCHAR2 := 'Y',
                        P_DEBUG_FLAG         IN VARCHAR2 DEFAULT 'N',
                        X_PROJECT_ID         OUT NUMBER,
                        X_NEW_PROJECT_NUMBER OUT VARCHAR2,
                        X_RETURN_STATUS      OUT VARCHAR2,
                        X_MSG_COUNT          OUT NUMBER,
                        X_MSG_DATA           OUT VARCHAR2) IS
    L_PROJECT_STATUS_CODE VARCHAR2(120);
    L_PROJECT_TYPE        VARCHAR2(20);
    L_ORG_ID              NUMBER;
    L_PRJ_NUM             VARCHAR2(240);
    L_ERR_CODE            NUMBER;
    L_ERR_STAGE           VARCHAR2(2000);
    L_ERR_STACK           VARCHAR2(2000);
    L_MSG_COUNT2          NUMBER;
    L_MSG_DATA2           VARCHAR2(2000);
    L_INDEX               NUMBER;
    L_DATA                VARCHAR2(1000);
    X_ERROR_MESSAGE       VARCHAR2(4000);
  
  BEGIN
  
    /* fnd_global.apps_initialize(user_id      => 0,
                               resp_id      => 50650,
                               resp_appl_id => 275);
    mo_global.set_policy_context('S', '81');*/
  
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT     := 0;
    X_MSG_DATA      := NULL;
    L_ERR_CODE      := 0;
    IF P_DEBUG_FLAG = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'Get Orig Project''s default information Start ...');
    END IF;
    -- Get Orig Project Value
    SELECT PPA.PROJECT_TYPE, PPT.DEF_START_PROJ_STATUS_CODE, PPA.ORG_ID
      INTO L_PROJECT_TYPE, L_PROJECT_STATUS_CODE, L_ORG_ID
      FROM PA_PROJECTS_ALL PPA, PA_PROJECT_TYPES_ALL PPT
     WHERE PPA.PROJECT_ID = P_ORIG_PROJECT_ID
       AND PPA.PROJECT_TYPE = PPT.PROJECT_TYPE
       AND PPT.ORG_ID = PPA.ORG_ID;
  
    IF P_DEBUG_FLAG = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'Get Orig Project''s default information End ...');
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'Output value l_project_type,l_project_status_code,l_org_id' ||
                        L_PROJECT_TYPE || ',' || L_PROJECT_STATUS_CODE || ',' ||
                        L_ORG_ID);
    END IF;
  
    IF P_DEBUG_FLAG = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'Calling xpjm_project_running_num_pub.gen_prj_num Start ..');
    END IF;
  
    -- Generate Project Number
    /*  xxpjm_project_running_num_pub.gen_prj_num(x_return_status   => x_return_status,
    x_msg_count       => x_msg_count,
    x_msg_data        => x_msg_data,
    x_prj_num         => l_prj_num,
    p_orig_project_id => p_orig_project_id);*/
    L_PRJ_NUM := P_PROJ_NUM;
    IF P_DEBUG_FLAG = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'Output value l_prj_num = ' || L_PRJ_NUM);
    END IF;
  
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
      X_MSG_DATA := 'Calling gen_prj_num Exception : ' || X_MSG_DATA;
      RETURN;
    END IF;
  
    IF L_PRJ_NUM IS NULL THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_DATA      := 'Calling xxpjm_project_running_num_pub.gen_prj_num Error ,Argument p_orig_project_id = ' ||
                         L_ORG_ID;
      RETURN;
    END IF;
    -- Call the procedure
    /* pa_project_core1.copy_project(x_orig_project_id          => p_orig_project_id,
    x_project_name             => l_prj_num,
    x_long_name                => p_long_name,
    x_project_number           => l_prj_num,
    x_description              => p_description,
    x_project_type             => l_project_type,
    x_project_status_code      => NULL,
    x_distribution_rule        => NULL,
    x_public_sector_flag       => NULL,
    x_organization_id          => l_org_id,
    x_start_date               => trunc(p_effective_date),
    x_completion_date          => NULL,
    x_probability_member_id    => NULL,
    x_project_value            => NULL,
    x_expected_approval_date   => NULL,
    x_agreement_currency       => NULL,
    x_agreement_amount         => NULL,
    x_agreement_org_id         => NULL,
    x_copy_task_flag           => 'Y',
    x_copy_budget_flag         => 'Y',
    x_use_override_flag        => 'Y',
    x_copy_assignment_flag     => 'Y',
    x_template_flag            => NULL,
    x_project_id               => x_project_id,
    x_err_code                 => l_err_code,
    x_err_stage                => l_err_stage,
    x_err_stack                => l_err_stack,
    x_customer_id              => NULL,
    x_new_project_number       => x_new_project_number,
    x_pm_product_code          => NULL,
    x_pm_project_reference     => NULL,
    x_project_currency_code    => NULL,
    x_attribute_category       => NULL,
    x_attribute1               => NULL,
    x_attribute2               => NULL,
    x_attribute3               => NULL,
    x_attribute4               => NULL,
    x_attribute5               => NULL,
    x_attribute6               => NULL,
    x_attribute7               => NULL,
    x_attribute8               => NULL,
    x_attribute9               => NULL,
    x_attribute10              => NULL,
    x_actual_start_date        => NULL,
    x_actual_finish_date       => NULL,
    x_early_start_date         => NULL,
    x_early_finish_date        => NULL,
    x_late_start_date          => NULL,
    x_late_finish_date         => NULL,
    x_scheduled_start_date     => NULL,
    x_scheduled_finish_date    => NULL,
    x_team_template_id         => NULL,
    x_country_code             => NULL,
    x_region                   => NULL,
    x_city                     => NULL,
    x_opp_value_currency_code  => NULL,
    x_org_project_copy_flag    => NULL,
    x_priority_code            => NULL,
    x_security_level           => NULL,
    p_en_top_task_cust_flag    => NULL,
    p_en_top_task_inv_mth_flag => NULL,
    p_date_eff_funds_flag      => NULL,
    p_ar_rec_notify_flag       => NULL,
    p_auto_release_pwp_inv     => NULL);*/
    /*pa_projects_maint_pub.create_project*/
    CREATE_PROJECT_PUB(P_API_VERSION                  => 1.0,
                       P_INIT_MSG_LIST                => NULL,
                       P_COMMIT                       => FND_API.G_FALSE,
                       P_VALIDATE_ONLY                => FND_API.G_FALSE,
                       P_VALIDATION_LEVEL             => NULL,
                       P_CALLING_MODULE               => NULL,
                       P_DEBUG_MODE                   => NULL,
                       P_MAX_MSG_COUNT                => NULL,
                       P_ORIG_PROJECT_ID              => P_ORIG_PROJECT_ID,
                       P_PROJECT_NAME                 => L_PRJ_NUM,
                       P_PROJECT_NUMBER               => L_PRJ_NUM,
                       P_DESCRIPTION                  => NULL,
                       P_PROJECT_TYPE                 => NULL,
                       P_PROJECT_STATUS_CODE          => NULL,
                       P_PROJECT_STATUS_NAME          => NULL,
                       P_DISTRIBUTION_RULE            => NULL,
                       P_PUBLIC_SECTOR_FLAG           => NULL,
                       P_CARRYING_OUT_ORGANIZATION_ID => NULL,
                       P_ORGANIZATION_NAME            => NULL,
                       P_START_DATE                   => NULL,
                       P_COMPLETION_DATE              => NULL,
                       P_PROBABILITY_MEMBER_ID        => NULL,
                       P_PROBABILITY_PERCENTAGE       => NULL,
                       P_PROJECT_VALUE                => NULL,
                       P_EXPECTED_APPROVAL_DATE       => NULL,
                       P_TEAM_TEMPLATE_ID             => NULL,
                       P_TEAM_TEMPLATE_NAME           => NULL,
                       P_COUNTRY_CODE                 => NULL,
                       P_COUNTRY_NAME                 => NULL,
                       P_REGION                       => NULL,
                       P_CITY                         => NULL,
                       P_CUSTOMER_ID                  => NULL,
                       P_CUSTOMER_NAME                => NULL,
                       P_AGREEMENT_CURRENCY           => NULL,
                       P_AGREEMENT_CURRENCY_NAME      => NULL,
                       P_AGREEMENT_AMOUNT             => NULL,
                       P_AGREEMENT_ORG_ID             => NULL,
                       P_AGREEMENT_ORG_NAME           => NULL,
                       P_OPP_VALUE_CURRENCY_CODE      => NULL,
                       P_OPP_VALUE_CURRENCY_NAME      => NULL,
                       P_PRIORITY_CODE                => NULL,
                       P_TEMPLATE_FLAG                => NULL,
                       P_SECURITY_LEVEL               => NULL,
                       P_BILL_TO_CUSTOMER_ID          => NULL,
                       P_SHIP_TO_CUSTOMER_ID          => NULL,
                       P_BILL_TO_CUSTOMER_NAME        => NULL,
                       P_SHIP_TO_CUSTOMER_NAME        => NULL,
                       P_COPY_TASK_FLAG               => 'N',
                       P_LONG_NAME                    => P_LONG_NAME,
                       P_PROJECT_ID                   => X_PROJECT_ID,
                       P_NEW_PROJECT_NUMBER           => X_NEW_PROJECT_NUMBER,
                       X_RETURN_STATUS                => X_RETURN_STATUS,
                       X_MSG_COUNT                    => X_MSG_COUNT,
                       X_MSG_DATA                     => X_MSG_DATA);
  
    FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
      PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                          P_MSG_INDEX     => I,
                                          P_MSG_COUNT     => X_MSG_COUNT,
                                          P_MSG_DATA      => X_MSG_DATA,
                                          P_DATA          => L_DATA,
                                          P_MSG_INDEX_OUT => L_INDEX);
      X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 255);
    END LOOP;
    /* FOR i IN 2 .. x_msg_count LOOP
      x_msg_data := fnd_msg_pub.get;
      xxfnd_conc_utl.log_msg(REPLACE(x_msg_data, chr(0), ' '));
    END LOOP;*/
    /*FOR i IN 1 .. 5 LOOP
        pa_interface_utils_pub.get_messages(p_encoded       => 'F',
                                            p_msg_index     => i,
                                            p_msg_count     => l_msg_count2,
                                            p_msg_data      => l_msg_data2,
                                            p_data          => l_data,
                                            p_msg_index_out => l_idx);
    \*    xxfnd_conc_utl.log_msg('l_msg_count2:  ' || l_msg_count2);
        xxfnd_conc_utl.log_msg('l_msg_data2: ' || l_msg_data2);
        xxfnd_conc_utl.log_msg('l_idx:  ' || l_idx);
        xxfnd_conc_utl.log_msg('l_data: ' || l_data);*\
        x_error_message := substrb(x_error_message || l_data, 1, 2000);
      END LOOP;
       IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'x_error_message:' || x_error_message);
         END IF;
      
       IF l_err_code <> 0 THEN
          x_return_status := fnd_api.g_ret_sts_error;
          x_msg_data      := 'Calling unit add_project''s Sub-program:copy_project Error ->' ||
                             l_err_stack;
          RETURN;
        END IF;*/
  
    IF X_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
      IF P_DEBUG_FLAG = 'Y' THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,
                          'Calling xxpa_proj_public_pvt.update_proj_key_member Start ... ');
      END IF;
      -- Update key member effective date
      log(X_PROJECT_ID);
      XXPA_PROJ_PUBLIC_PVT.UPDATE_PROJ_KEY_MEMBER(P_PROJECT_ID     => X_PROJECT_ID,
                                                  P_EFFECTIVE_DATE => P_EFFECTIVE_DATE,
                                                  X_RETURN_STATUS  => X_RETURN_STATUS,
                                                  X_MSG_COUNT      => X_MSG_COUNT,
                                                  X_MSG_DATA       => X_MSG_DATA);
    
      IF P_DEBUG_FLAG = 'Y' THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,
                          'Calling xxpa_proj_public_pvt.update_proj_key_member Status = ' ||
                          X_RETURN_STATUS || ' ,' || X_MSG_DATA);
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      L_ERR_CODE      := -20001;
      L_ERR_STAGE     := 'Calling xxpa_proj_public_pvt.add_project API Occured Exception Error ' ||
                         SQLERRM;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_DATA      := L_ERR_STAGE;
  END ADD_PROJECT;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  ADD_PRJ_TOP_TASK
  *
  *   DESCRIPTION: Get user defalut DRP option Parameters
  *
  *   ARGUMENT:   
  *                         
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 2012-01-11 Siman.he
  *                     Creation Description
  * =============================================*/
  PROCEDURE ADD_PROJ_TOP_TASK IS
    L_DATE_OFFSET NUMBER;
  BEGIN
    NULL;
  END ADD_PROJ_TOP_TASK;

  PROCEDURE GET_TASK_REF(P_TASK_ID  IN NUMBER,
                         X_TASK_REC OUT PA_TASKS%ROWTYPE) IS
  BEGIN
    X_TASK_REC := NULL;
    SELECT * INTO X_TASK_REC FROM PA_TASKS WHERE TASK_ID = P_TASK_ID;
  END;

  /* =============================================
  *   PROCEDURE
  *   NAME :  ADD_PRJ_TASK
  *
  *   DESCRIPTION: If DRP's workbench bucket date is not exists ,The program
  *                Units will be generate a new workbench bucket date
  *
  *   ARGUMENT:   
  *                         
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 mm/dd/yyyy Author Name
  *                     Creation Description
  * =============================================*/
  PROCEDURE ADD_PROJ_TASK(P_PROJECT_ID            NUMBER,
                          P_STRUCTURE_VERSION_ID  NUMBER,
                          P_TASK_NAME             VARCHAR2,
                          P_TASK_NUMBER           VARCHAR2,
                          P_TASK_DESCRIPTION      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                          P_SCHEDULED_START_DATE  DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                          P_SCHEDULED_FINISH_DATE DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                          P_PARENT_TASK_ID        NUMBER,
                          P_TASK_TYPE             NUMBER,
                          X_TASK_ID               OUT NUMBER,
                          X_RETURN_STATUS         OUT VARCHAR2,
                          X_MSG_COUNT             OUT NUMBER,
                          X_MSG_DATA              OUT VARCHAR2) IS
    X_PROJECT_ID     NUMBER;
    X_PROJECT_NUMBER PA_PROJECTS_ALL.SEGMENT1%TYPE;
    L_INDEX          NUMBER;
    L_DATA           VARCHAR2(1000);
  BEGIN
  
    PA_PROJECT_PUB.ADD_TASK(P_API_VERSION_NUMBER    => 1.0,
                            P_MSG_COUNT             => X_MSG_COUNT,
                            P_MSG_DATA              => X_MSG_DATA,
                            P_RETURN_STATUS         => X_RETURN_STATUS,
                            P_PM_PRODUCT_CODE       => NULL,
                            P_PA_PROJECT_ID         => P_PROJECT_ID,
                            P_PM_TASK_REFERENCE     => P_TASK_NAME ||
                                                       P_PARENT_TASK_ID,
                            P_PA_TASK_NUMBER        => P_TASK_NUMBER,
                            P_TASK_NAME             => P_TASK_NAME,
                            P_TASK_DESCRIPTION      => P_TASK_DESCRIPTION,
                            P_SCHEDULED_START_DATE  => P_SCHEDULED_START_DATE,
                            P_SCHEDULED_FINISH_DATE => P_SCHEDULED_FINISH_DATE,
                            P_PA_PARENT_TASK_ID     => P_PARENT_TASK_ID,
                            P_STRUCTURE_VERSION_ID  => P_STRUCTURE_VERSION_ID,
                            --p_financial_task_flag  => 'Y',
                            P_STRUCTURE_TYPE        => 'WORKPLAN',
                            P_PA_PROJECT_ID_OUT     => X_PROJECT_ID,
                            P_PA_PROJECT_NUMBER_OUT => X_PROJECT_NUMBER,
                            P_TASK_TYPE             => P_TASK_TYPE,
                            P_TASK_ID               => X_TASK_ID
                            /*p_tasks_dff             => 'Y',
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    p_attribute3            => 'CKD Parts Design'*/);
    FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
      PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                          P_MSG_INDEX     => I,
                                          P_MSG_COUNT     => X_MSG_COUNT,
                                          P_MSG_DATA      => X_MSG_DATA,
                                          P_DATA          => L_DATA,
                                          P_MSG_INDEX_OUT => L_INDEX);
      X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 255);
    END LOOP;
  END ADD_PROJ_TASK;

  /*==================================================
  Program Name:
      update_proj_task
  Description:
      update project task
  History:
      1.00  2012/2/29 21:33:33  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE UPDATE_PROJ_ELEMENT(P_DEBUG_MODE            IN VARCHAR2 := 'N',
                                P_CHARGEABLE_FLAG       IN VARCHAR2,
                                P_PROJ_ELEMENT_ID       IN NUMBER,
                                P_ELEMENT_NUMBER        IN VARCHAR2,
                                P_ELEMENT_NAME          IN VARCHAR2,
                                P_RECORD_VERSION_NUMBER IN NUMBER, --pa_proj_elements.record_version_number
                                -- xxlu added task DFF attributes
                                P_TK_ATTRIBUTE_CATEGORY IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE1         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE2         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE3         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE4         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE5         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE6         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE7         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE8         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE9         IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                P_TK_ATTRIBUTE10        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
                                X_MSG_COUNT             OUT NOCOPY NUMBER,
                                X_MSG_DATA              OUT NOCOPY VARCHAR2) IS
    L_API_NAME       CONSTANT VARCHAR2(30) := 'update_proj_task';
    L_SAVEPOINT_NAME CONSTANT VARCHAR2(30) := '';
    L_INDEX NUMBER;
    L_DATA  VARCHAR2(1000);
  BEGIN
    PA_TASK_PVT1.UPDATE_TASK(P_VALIDATE_ONLY   => FND_API.G_FALSE,
                             P_DEBUG_MODE      => P_DEBUG_MODE,
                             P_CHARGEABLE_FLAG => P_CHARGEABLE_FLAG,
                             /*  p_max_msg_count => :p_max_msg_count,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_ref_task_id => :p_ref_task_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_peer_or_sub => :p_peer_or_sub,*/
                             P_TASK_ID               => P_PROJ_ELEMENT_ID,
                             P_TASK_NUMBER           => P_ELEMENT_NUMBER,
                             P_TASK_NAME             => P_ELEMENT_NAME,
                             P_TK_ATTRIBUTE_CATEGORY => P_TK_ATTRIBUTE_CATEGORY,
                             P_TK_ATTRIBUTE1         => P_TK_ATTRIBUTE1,
                             P_TK_ATTRIBUTE2         => P_TK_ATTRIBUTE2,
                             P_TK_ATTRIBUTE3         => P_TK_ATTRIBUTE3,
                             P_TK_ATTRIBUTE4         => P_TK_ATTRIBUTE4,
                             P_TK_ATTRIBUTE5         => P_TK_ATTRIBUTE5,
                             P_TK_ATTRIBUTE6         => P_TK_ATTRIBUTE6,
                             P_TK_ATTRIBUTE7         => P_TK_ATTRIBUTE7,
                             P_TK_ATTRIBUTE8         => P_TK_ATTRIBUTE8,
                             P_TK_ATTRIBUTE9         => P_TK_ATTRIBUTE9,
                             P_TK_ATTRIBUTE10        => P_TK_ATTRIBUTE10,
                             /* p_task_description => :p_task_description,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_location_id => :p_location_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_country => :p_country,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_territory_code => :p_territory_code,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_state_region => :p_state_region,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_city => :p_city,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_task_manager_id => :p_task_manager_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_carrying_out_org_id => :p_carrying_out_org_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_priority_code => :p_priority_code,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_type_id => :p_type_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_status_code => :p_status_code,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_inc_proj_progress_flag => :p_inc_proj_progress_flag,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_pm_product_code => :p_pm_product_code,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_pm_task_reference => :p_pm_task_reference,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_closed_date => :p_closed_date,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_transaction_start_date => :p_transaction_start_date,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_transaction_finish_date => :p_transaction_finish_date,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute_category => :p_attribute_category,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute1 => :p_attribute1,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute2 => :p_attribute2,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute3 => :p_attribute3,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute4 => :p_attribute4,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute5 => :p_attribute5,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute6 => :p_attribute6,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute7 => :p_attribute7,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute8 => :p_attribute8,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute9 => :p_attribute9,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute10 => :p_attribute10,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute11 => :p_attribute11,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute12 => :p_attribute12,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute13 => :p_attribute13,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute14 => :p_attribute14,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_attribute15 => :p_attribute15,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_address_id => :p_address_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_address1 => :p_address1,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_work_type_id => :p_work_type_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_service_type_code => :p_service_type_code,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_chargeable_flag => :p_chargeable_flag,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_billable_flag => :p_billable_flag,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_receive_project_invoice_flag => :p_receive_project_invoice_flag,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_task_weighting_deriv_code => :p_task_weighting_deriv_code,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_work_item_code => :p_work_item_code,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_uom_code => :p_uom_code,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_wq_actual_entry_code => :p_wq_actual_entry_code,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_task_progress_entry_page_id => :p_task_progress_entry_page_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_task_progress_entry_page => :p_task_progress_entry_page,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_phase_version_id => :p_phase_version_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_parent_structure_id => :p_parent_structure_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_phase_code => :p_phase_code,*/
                             P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
                             /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_base_perc_comp_deriv_code => :p_base_perc_comp_deriv_code,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_gen_etc_src_code => :p_gen_etc_src_code,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_wf_item_type => :p_wf_item_type,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_wf_process => :p_wf_process,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_wf_lead_days => :p_wf_lead_days,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_wf_enabled_flag => :p_wf_enabled_flag,*/
                             X_RETURN_STATUS => X_RETURN_STATUS,
                             X_MSG_COUNT     => X_MSG_COUNT,
                             X_MSG_DATA      => X_MSG_DATA /*,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      p_shared => :p_shared*/);
    LOG('************************12');
    LOG('x_return_status:' || X_RETURN_STATUS);
    LOG('x_msg_count:' || X_MSG_COUNT);
    FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
      PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                          P_MSG_INDEX     => I,
                                          P_MSG_COUNT     => X_MSG_COUNT,
                                          P_MSG_DATA      => X_MSG_DATA,
                                          P_DATA          => L_DATA,
                                          P_MSG_INDEX_OUT => L_INDEX);
      X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 255);
    END LOOP;
    LOG('x_msg_data:' || X_MSG_DATA);
  EXCEPTION
    WHEN OTHERS THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_DATA      := 'Calling update_proj_element Occurred Error ' ||
                         SQLERRM;
  END UPDATE_PROJ_ELEMENT;

  /*==================================================
  Program Name:
      add_task_resource_assignment
  Description:
      add task resource assignment
  History:
      1.00  2012/2/29 16:17:48  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE ADD_TASK_RESOURCE_ASSIGNMENT(P_PROJECT_ID IN NUMBER,
                                         /* p_pa_structure_version_id  IN NUMBER,*/
                                         P_TASK_ID                  IN NUMBER,
                                         PA_TASK_ELEMENT_VERSION_ID IN NUMBER,
                                         P_RESOURCE_LIST_MEMBER_ID  IN NUMBER,
                                         P_PLANNED_QUANTITY         IN NUMBER,
                                         P_PM_PRODUCT_CODE          IN VARCHAR2,
                                         P_PM_TASK_ASGMT_REFERENCE  IN VARCHAR2,
                                         X_RETURN_STATUS            OUT NOCOPY VARCHAR2,
                                         X_MSG_COUNT                OUT NOCOPY NUMBER,
                                         X_MSG_DATA                 OUT NOCOPY VARCHAR2) IS
    L_API_NAME       CONSTANT VARCHAR2(30) := 'add_task_resource_assignment';
    L_SAVEPOINT_NAME CONSTANT VARCHAR2(30) := '';
    P_TASK_ASSIGNMENTS_IN  PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_IN_TBL_TYPE;
    P_TASK_ASSIGNMENTS_OUT PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_OUT_TBL_TYPE;
    L_INDEX                NUMBER;
    L_DATA                 VARCHAR2(1000);
  BEGIN
    P_TASK_ASSIGNMENTS_IN(1).PA_PROJECT_ID := P_PROJECT_ID;
    -- p_task_assignments_in(1).pa_structure_version_id := 353108;
    P_TASK_ASSIGNMENTS_IN(1).PA_TASK_ID := P_TASK_ID;
    P_TASK_ASSIGNMENTS_IN(1).RESOURCE_LIST_MEMBER_ID := P_RESOURCE_LIST_MEMBER_ID;
    P_TASK_ASSIGNMENTS_IN(1).PLANNED_QUANTITY := P_PLANNED_QUANTITY;
    P_TASK_ASSIGNMENTS_IN(1).PM_TASK_ASGMT_REFERENCE := P_PM_TASK_ASGMT_REFERENCE;
    P_TASK_ASSIGNMENTS_IN(1).PLANNED_TOTAL_RAW_COST := 0;
    P_TASK_ASSIGNMENTS_IN(1).planned_total_bur_cost := 0;
    P_TASK_ASSIGNMENTS_IN(1).PA_TASK_ELEMENT_VERSION_ID := PA_TASK_ELEMENT_VERSION_ID;
    p_task_assignments_in(1).raw_cost_rate_override := 0;
    p_task_assignments_in(1).burd_cost_rate_override := 0;
    PA_TASK_ASSIGNMENTS_PUB.CREATE_TASK_ASSIGNMENTS(P_API_VERSION_NUMBER => 1.0,
                                                    P_PM_PRODUCT_CODE    => P_PM_PRODUCT_CODE,
                                                    P_PA_PROJECT_ID      => P_PROJECT_ID,
                                                    /*   p_pa_structure_version_id => p_pa_structure_version_id,*/
                                                    P_TASK_ASSIGNMENTS_IN  => P_TASK_ASSIGNMENTS_IN,
                                                    P_TASK_ASSIGNMENTS_OUT => P_TASK_ASSIGNMENTS_OUT,
                                                    X_MSG_COUNT            => X_MSG_COUNT,
                                                    X_MSG_DATA             => X_MSG_DATA,
                                                    X_RETURN_STATUS        => X_RETURN_STATUS);
  
    FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
      PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                          P_MSG_INDEX     => I,
                                          P_MSG_COUNT     => X_MSG_COUNT,
                                          P_MSG_DATA      => X_MSG_DATA,
                                          P_DATA          => L_DATA,
                                          P_MSG_INDEX_OUT => L_INDEX);
      X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 255);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_DATA      := 'Calling add_task_resource_assignment Occurred Error ' ||
                         SQLERRM;
  END ADD_TASK_RESOURCE_ASSIGNMENT;

  /*==================================================
  Program Name:
      delete_proj_task
  Description:
      delete project task
  History:
      1.00  2012/2/29 10:21:04  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE DELETE_PROJ_TASK(P_PROJECT_ID    IN NUMBER,
                             P_TASK_ID       IN NUMBER,
                             X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                             X_MSG_COUNT     OUT NOCOPY NUMBER,
                             X_MSG_DATA      OUT NOCOPY VARCHAR2) IS
    L_API_NAME       CONSTANT VARCHAR2(30) := 'delete_proj_task';
    L_SAVEPOINT_NAME CONSTANT VARCHAR2(30) := '';
    X_PROJECT_ID NUMBER;
    X_TASK_ID    NUMBER;
    L_INDEX      NUMBER;
    L_DATA       VARCHAR2(1000);
  BEGIN
    PA_PROJECT_PUB.DELETE_TASK(P_API_VERSION_NUMBER   => 1.0,
                               P_MSG_COUNT            => X_MSG_COUNT,
                               P_MSG_DATA             => X_MSG_DATA,
                               P_RETURN_STATUS        => X_RETURN_STATUS,
                               P_PM_PRODUCT_CODE      => NULL,
                               P_PA_PROJECT_ID        => P_PROJECT_ID,
                               P_PA_TASK_ID           => P_TASK_ID,
                               P_CASCADED_DELETE_FLAG => 'Y',
                               P_TASK_VERSION_ID      => XXPJM_PROJECT_PUBLIC.GET_CURRENT_WORKING_VER_ID(P_TASK_ID),
                               /*   p_structure_type       => 'WORKPLAN',*/
                               P_PROJECT_ID => X_PROJECT_ID,
                               P_TASK_ID    => X_TASK_ID);
    FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
      PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                          P_MSG_INDEX     => I,
                                          P_MSG_COUNT     => X_MSG_COUNT,
                                          P_MSG_DATA      => X_MSG_DATA,
                                          P_DATA          => L_DATA,
                                          P_MSG_INDEX_OUT => L_INDEX);
      X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 255);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_DATA      := 'Calling delete_proj_task Occurred Error ' ||
                         SQLERRM;
  END DELETE_PROJ_TASK;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  ADD_PROJ_CUSTOMER
  *
  *   DESCRIPTION: Create an project's Customer
  *              
  *   ARGUMENT:   
  *                         
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 mm/dd/yyyy siman.he 
  *                     Creation Description
  * =============================================*/
  PROCEDURE ADD_PROJ_CUSTOMER(P_PROJECT_ID          IN NUMBER,
                              P_CUSTOMER_ID         IN NUMBER,
                              P_BILL_TO_ADDRESS_ID  IN NUMBER,
                              P_SHIP_TO_ADDRESS_ID  IN NUMBER,
                              P_CUSTOMER_BILL_SPLIT IN NUMBER,
                              P_INV_CURRENCY_CODE   IN VARCHAR2,
                              P_ORG_ID              IN NUMBER,
                              X_RETURN_STATUS       OUT VARCHAR2,
                              X_MSG_COUNT           OUT NUMBER,
                              X_MSG_DATA            OUT VARCHAR2) IS
    L_MSG_COUNT          NUMBER;
    L_DEFAULT_RATE_TYPE  VARCHAR2(80);
    L_CUSTOMER_ID        NUMBER;
    L_SHIP_TO_ADDRESS_ID NUMBER;
    L_BILL_TO_ADDRESS_ID NUMBER;
    L_DATA               VARCHAR2(2000);
    L_INDEX              NUMBER;
  BEGIN
  
    /*  fnd_global.apps_initialize(user_id      => 0,
                               resp_id      => 50650,
                               resp_appl_id => 275);
    mo_global.set_policy_context('S', '81');*/
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_DATA      := NULL;
  
    IF CHECK_CUSTOMER_VALID(P_CUSTOMER_ID) = 'N' THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_DATA      := 'Customer is not valid';
      RETURN;
    END IF;
  
    IF CHECK_CUST_ADDR_VALID(P_BILL_TO_ADDRESS_ID, 'BILL_TO') = 'N' THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_DATA      := 'Customer bill_to_address_id is not valid';
      RETURN;
    END IF;
  
    IF CHECK_CUST_ADDR_VALID(P_SHIP_TO_ADDRESS_ID, 'SHIP_TO') = 'N' THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_DATA      := 'Customer ship_to_address_id is not valid';
      RETURN;
    END IF;
  
    SELECT PIA.DEFAULT_RATE_TYPE
      INTO L_DEFAULT_RATE_TYPE
      FROM PA_IMPLEMENTATIONS_ALL PIA
     WHERE ORG_ID = P_ORG_ID;
    PA_CUSTOMERS_CONTACTS_PUB.CREATE_PROJECT_CUSTOMER(P_API_VERSION                => 1.0,
                                                      P_INIT_MSG_LIST              => 'T',
                                                      P_COMMIT                     => 'F',
                                                      P_VALIDATE_ONLY              => 'F',
                                                      P_VALIDATION_LEVEL           => 100,
                                                      P_CALLING_MODULE             => 'FORM',
                                                      P_DEBUG_MODE                 => 'N',
                                                      P_MAX_MSG_COUNT              => NULL,
                                                      P_PROJECT_ID                 => P_PROJECT_ID,
                                                      P_CUSTOMER_ID                => P_CUSTOMER_ID,
                                                      P_CUSTOMER_NAME              => NULL,
                                                      P_CUSTOMER_NUMBER            => NULL,
                                                      P_PROJECT_RELATIONSHIP_CODE  => 'PRIMARY',
                                                      P_CUSTOMER_BILL_SPLIT        => P_CUSTOMER_BILL_SPLIT,
                                                      P_BILL_TO_CUSTOMER_ID        => P_CUSTOMER_ID,
                                                      P_SHIP_TO_CUSTOMER_ID        => P_CUSTOMER_ID,
                                                      P_BILL_TO_ADDRESS_ID         => P_BILL_TO_ADDRESS_ID,
                                                      P_SHIP_TO_ADDRESS_ID         => P_SHIP_TO_ADDRESS_ID,
                                                      P_BILL_TO_CUSTOMER_NAME      => NULL,
                                                      P_BILL_TO_CUSTOMER_NUMBER    => NULL,
                                                      P_SHIP_TO_CUSTOMER_NAME      => NULL,
                                                      P_SHIP_TO_CUSTOMER_NUMBER    => NULL,
                                                      P_BILL_SITE_NAME             => NULL,
                                                      P_WORK_SITE_NAME             => NULL,
                                                      P_INV_CURRENCY_CODE          => P_INV_CURRENCY_CODE,
                                                      P_INV_RATE_TYPE              => L_DEFAULT_RATE_TYPE,
                                                      P_INV_RATE_DATE              => NULL,
                                                      P_INV_EXCHANGE_RATE          => NULL,
                                                      P_ALLOW_USER_RATE_TYPE_FLAG  => 'N',
                                                      P_RECEIVER_TASK_ID           => NULL,
                                                      X_CUSTOMER_ID                => L_CUSTOMER_ID,
                                                      X_RETURN_STATUS              => X_RETURN_STATUS,
                                                      X_MSG_COUNT                  => X_MSG_COUNT,
                                                      X_MSG_DATA                   => X_MSG_DATA,
                                                      P_PROJECT_PARTY_ID           => NULL,
                                                      P_DEFAULT_TOP_TASK_CUST_FLAG => 'N',
                                                      P_EN_TOP_TASK_CUST_FLAG      => 'N');
    FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
      PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                          P_MSG_INDEX     => I,
                                          P_MSG_COUNT     => X_MSG_COUNT,
                                          P_MSG_DATA      => X_MSG_DATA,
                                          P_DATA          => L_DATA,
                                          P_MSG_INDEX_OUT => L_INDEX);
      X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 255);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      X_MSG_DATA      := SQLERRM;
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
  END;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  update_project_customer
  *
  *   DESCRIPTION: update an project's Customer
  *              
  *   ARGUMENT:   
  *                         
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 mm/dd/yyyy ouzhiwei
  *                     Creation Description
  * =============================================*/
  PROCEDURE UPDATE_PROJECT_CUSTOMER(P_PROJECT_ID                IN NUMBER,
                                    P_CUSTOMER_ID               IN NUMBER,
                                    P_RECORD_VERSION_NUMBER     IN NUMBER,
                                    P_BILL_TO_ADDRESS_ID        IN NUMBER,
                                    P_SHIP_TO_ADDRESS_ID        IN NUMBER,
                                    P_PROJECT_RELATIONSHIP_CODE IN VARCHAR2,
                                    P_CUSTOMER_BILL_SPLIT       IN NUMBER,
                                    P_INV_CURRENCY_CODE         IN VARCHAR2,
                                    P_INV_RATE_TYPE             IN VARCHAR2,
                                    X_RETURN_STATUS             OUT VARCHAR2,
                                    X_MSG_COUNT                 OUT NUMBER,
                                    X_MSG_DATA                  OUT VARCHAR2) IS
    L_MSG_COUNT          NUMBER;
    L_DEFAULT_RATE_TYPE  VARCHAR2(80);
    L_CUSTOMER_ID        NUMBER;
    L_SHIP_TO_ADDRESS_ID NUMBER;
    L_BILL_TO_ADDRESS_ID NUMBER;
    L_DATA               VARCHAR2(2000);
    L_INDEX              NUMBER;
  BEGIN
  
    /*  fnd_global.apps_initialize(user_id      => 0,
                               resp_id      => 50650,
                               resp_appl_id => 275);
    mo_global.set_policy_context('S', '81');*/
  
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_DATA      := NULL;
  
    IF CHECK_CUSTOMER_VALID(P_CUSTOMER_ID) = 'N' THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_DATA      := 'Customer is not valid';
      RETURN;
    END IF;
  
    /* L_BILL_TO_ADDRESS_ID := check_cust_addr_valid(p_bill_to_site_use_id,'BILL_TO') ;
    IF L_BILL_TO_ADDRESS_ID IS NULL  THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := 'Customer bill_to_address_id is not valid';
      RETURN;
    END IF;
    
    L_SHIP_TO_ADDRESS_ID := check_cust_addr_valid(p_ship_to_site_use_id,'SHIP_TO');
    IF L_SHIP_TO_ADDRESS_ID IS NULL  THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := 'Customer ship_to_address_id is not valid';
      RETURN;
    END IF;*/
    /* 
    SELECT pia.default_rate_type
      INTO l_default_rate_type
      FROM pa_implementations_all pia
     WHERE org_id = p_org_id;*/
  
    PA_CUSTOMERS_CONTACTS_PUB.UPDATE_PROJECT_CUSTOMER(P_API_VERSION      => 1.0,
                                                      P_INIT_MSG_LIST    => 'T',
                                                      P_COMMIT           => 'F',
                                                      P_VALIDATE_ONLY    => 'F',
                                                      P_VALIDATION_LEVEL => 100,
                                                      /*    p_calling_module             => 'FORM',*/
                                                      /*  p_debug_mode                 => 'N',
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              p_max_msg_count              => NULL,*/
                                                      P_PROJECT_ID  => P_PROJECT_ID,
                                                      P_CUSTOMER_ID => P_CUSTOMER_ID,
                                                      /*    p_customer_name              => NULL,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              p_customer_number            => NULL,*/
                                                      P_PROJECT_RELATIONSHIP_CODE => P_PROJECT_RELATIONSHIP_CODE,
                                                      P_CUSTOMER_BILL_SPLIT       => P_CUSTOMER_BILL_SPLIT,
                                                      P_BILL_TO_CUSTOMER_ID       => P_CUSTOMER_ID,
                                                      P_SHIP_TO_CUSTOMER_ID       => P_CUSTOMER_ID,
                                                      P_RECORD_VERSION_NUMBER     => P_RECORD_VERSION_NUMBER,
                                                      P_BILL_TO_ADDRESS_ID        => P_BILL_TO_ADDRESS_ID,
                                                      P_SHIP_TO_ADDRESS_ID        => P_SHIP_TO_ADDRESS_ID,
                                                      /*     p_bill_to_customer_name      =>NULL,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              p_bill_to_customer_number    => NULL,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              p_ship_to_customer_name      => NULL,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              p_ship_to_customer_number    => NULL,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              p_bill_site_name             => NULL,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              p_work_site_name             => NULL,*/
                                                      P_INV_CURRENCY_CODE => P_INV_CURRENCY_CODE,
                                                      P_INV_RATE_TYPE     => P_INV_RATE_TYPE,
                                                      /*  p_inv_rate_date              => NULL,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              p_inv_exchange_rate          => NULL,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              p_allow_user_rate_type_flag  => 'N',
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              p_receiver_task_id           => NULL,*/
                                                      /*  x_customer_id                => l_customer_id,*/
                                                      X_RETURN_STATUS => X_RETURN_STATUS,
                                                      X_MSG_COUNT     => X_MSG_COUNT,
                                                      X_MSG_DATA      => X_MSG_DATA,
                                                      /*  p_project_party_id           => NULL,*/
                                                      P_DEFAULT_TOP_TASK_CUST_FLAG => 'N' /*,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              p_en_top_task_cust_flag      => 'N'*/);
  
    FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
      PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                          P_MSG_INDEX     => I,
                                          P_MSG_COUNT     => X_MSG_COUNT,
                                          P_MSG_DATA      => X_MSG_DATA,
                                          P_DATA          => L_DATA,
                                          P_MSG_INDEX_OUT => L_INDEX);
      X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 255);
    END LOOP;
  END;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  ADD_AGREEMENTS_FUNDING
  *
  *   DESCRIPTION: 
  *
  *   ARGUMENT: p_project_id        Project ID  
  *             p_agreement_id      Agreement ID
  *             p_allocated_amount  Agreement's Funding Amount
  *             p_date_allocated    Funding's Date Allocated
  *             p_task_id           Project Task ID  
  *   RETURN:
  *             x_project_funding_id      Project Funding ID   
  *   HISTORY:
  *     1.00 2012-01-11 Siman.he
  *       
  * =============================================*/
  PROCEDURE ADD_FUNDING(P_PROJECT_ID         IN NUMBER,
                        P_AGREEMENT_ID       IN NUMBER,
                        P_ALLOCATED_AMOUNT   IN NUMBER,
                        P_DATE_ALLOCATED     IN DATE,
                        P_TASK_ID            IN NUMBER,
                        P_ATTRIBUTE_CATEGORY IN VARCHAR2,
                        P_ATTRIBUTE1         IN VARCHAR2,
                        P_ATTRIBUTE2         IN VARCHAR2,
                        P_ATTRIBUTE3         IN VARCHAR2,
                        P_ATTRIBUTE4         IN VARCHAR2,
                        P_ATTRIBUTE5         IN VARCHAR2,
                        P_ATTRIBUTE6         IN VARCHAR2,
                        P_ATTRIBUTE7         IN VARCHAR2,
                        P_ATTRIBUTE8         IN VARCHAR2,
                        P_ATTRIBUTE9         IN VARCHAR2,
                        P_ATTRIBUTE10        IN VARCHAR2,
                        X_PROJECT_FUNDING_ID IN OUT NUMBER,
                        X_MSG_COUNT          OUT NUMBER,
                        X_RETURN_STATUS      OUT VARCHAR2,
                        X_MSG_DATA           OUT VARCHAR2) IS
    L_ROW_ID             VARCHAR2(50);
    L_CURRENCY_CODE      VARCHAR2(40);
    L_DEFAULT_RATE_TYPE  VARCHAR2(240);
    L_PROJECT_FUNDING_ID NUMBER;
    L_FUNDING_ID         NUMBER;
  BEGIN
    X_MSG_COUNT     := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_DATA      := NULL;
  
    SELECT PAA.AGREEMENT_CURRENCY_CODE, PIA.DEFAULT_RATE_TYPE
      INTO L_CURRENCY_CODE, L_DEFAULT_RATE_TYPE
      FROM PA_AGREEMENTS_ALL PAA, PA_IMPLEMENTATIONS PIA
     WHERE PAA.AGREEMENT_ID = P_AGREEMENT_ID
       AND PAA.ORG_ID = PIA.ORG_ID;
  
    --SELECT pa_project_fundings_s.NEXTVAL INTO l_funding_id FROM dual;
  
    PA_AGREEMENT_PUB.ADD_FUNDING(P_API_VERSION_NUMBER     => 1.0,
                                 P_COMMIT                 => 'F',
                                 P_INIT_MSG_LIST          => 'F',
                                 P_MSG_COUNT              => X_MSG_COUNT,
                                 P_MSG_DATA               => X_MSG_DATA,
                                 P_RETURN_STATUS          => X_RETURN_STATUS,
                                 P_PM_PRODUCT_CODE        => 'PA_PRJ', -- Required Fileds
                                 P_PM_FUNDING_REFERENCE   => P_AGREEMENT_ID, -- Required Fileds
                                 P_FUNDING_ID             => L_FUNDING_ID,
                                 P_PA_PROJECT_ID          => P_PROJECT_ID, -- Required Fileds
                                 P_PA_TASK_ID             => P_TASK_ID, -- Required Fileds
                                 P_AGREEMENT_ID           => P_AGREEMENT_ID, --Required Fileds
                                 P_ALLOCATED_AMOUNT       => P_ALLOCATED_AMOUNT,
                                 P_DATE_ALLOCATED         => P_DATE_ALLOCATED,
                                 P_DESC_FLEX_NAME         => NULL,
                                 P_ATTRIBUTE_CATEGORY     => P_ATTRIBUTE_CATEGORY,
                                 P_ATTRIBUTE1             => P_ATTRIBUTE1,
                                 P_ATTRIBUTE2             => P_ATTRIBUTE2,
                                 P_ATTRIBUTE3             => P_ATTRIBUTE3,
                                 P_ATTRIBUTE4             => P_ATTRIBUTE4,
                                 P_ATTRIBUTE5             => P_ATTRIBUTE5,
                                 P_ATTRIBUTE6             => P_ATTRIBUTE6,
                                 P_ATTRIBUTE7             => P_ATTRIBUTE7,
                                 P_ATTRIBUTE8             => P_ATTRIBUTE8,
                                 P_ATTRIBUTE9             => P_ATTRIBUTE9,
                                 P_ATTRIBUTE10            => P_ATTRIBUTE10,
                                 P_FUNDING_ID_OUT         => X_PROJECT_FUNDING_ID,
                                 P_PROJECT_RATE_TYPE      => L_DEFAULT_RATE_TYPE,
                                 P_PROJECT_RATE_DATE      => NULL,
                                 P_PROJECT_EXCHANGE_RATE  => NULL,
                                 P_PROJFUNC_RATE_TYPE     => L_DEFAULT_RATE_TYPE,
                                 P_PROJFUNC_RATE_DATE     => NULL,
                                 P_PROJFUNC_EXCHANGE_RATE => NULL,
                                 P_FUNDING_CATEGORY       => 'ORIGINAL');
  
    /*pa_project_fundings_pkg.insert_row(x_rowid                => l_row_id,
    x_project_funding_id   => x_project_funding_id,
    x_last_update_date     => SYSDATE, 
    x_last_updated_by      => fnd_global.user_id, 
    x_creation_date        => SYSDATE, 
    x_created_by           => fnd_global.user_id, 
    x_last_update_login    => fnd_global.login_id, 
    x_agreement_id         => p_agreement_id,
    x_project_id           => p_project_id,
    x_task_id              => p_task_id,
    x_budget_type_code     => 'DRAFT',
    x_allocated_amount     => p_allocated_amount,
    x_date_allocated       => p_date_allocated,
    x_attribute_category   => NULL,
    x_control_item_id      => NULL,
    x_attribute1           => NULL, --attribute1,
    x_attribute2           => NULL, --attribute2,
    x_attribute3           => NULL,
    x_attribute4           => NULL,
    x_attribute5           => NULL,
    x_attribute6           => NULL,
    x_attribute7           => NULL,
    x_attribute8           => NULL,
    x_attribute9           => NULL,
    x_attribute10          => NULL,
    x_pm_funding_reference => NULL,
    x_pm_product_code      => NULL,
    -- Following are MCB2 columns
    x_funding_currency_code     => l_currency_code,
    x_project_currency_code     => l_currency_code,
    x_project_rate_type         => l_default_rate_type,
    x_project_rate_date         => NULL,
    x_project_exchange_rate     => NULL,
    x_project_allocated_amount  => p_allocated_amount,
    x_projfunc_currency_code    => l_currency_code,
    x_projfunc_rate_type        => l_default_rate_type,
    x_projfunc_rate_date        => NULL,
    x_projfunc_exchange_rate    => NULL,
    x_projfunc_allocated_amount => p_allocated_amount,
    x_invproc_currency_code     => l_currency_code,
    x_invproc_rate_type         => l_default_rate_type,
    x_invproc_rate_date         => NULL,
    x_invproc_exchange_rate     => NULL,
    x_invproc_allocated_amount  => p_allocated_amount,
    x_revproc_currency_code     => l_currency_code,
    x_revproc_rate_type         => 'Corporate',
    x_revproc_rate_date         => NULL,
    x_revproc_exchange_rate     => NULL,
    x_revproc_allocated_amount  => p_allocated_amount,
    x_funding_category          => 'ORIGINAL'); */
  EXCEPTION
    WHEN OTHERS THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_DATA      := 'Calling pa_project_fundings_pkg.insert_row Occurred Exception :' ||
                         SQLERRM;
  END;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  ADD_AGREEMENTS
  *
  *   DESCRIPTION: 
  *
  *   ARGUMENT: p_customer_id       Customer ID   
  *             p_org_id            Org ID 
  *             p_agreement_num     Agreement Number 
  *             p_agreement_type    Original Agreemnet/VO Agreement
  *             p_agreement_amount  Amount 
  *             p_currency_code     Agreemnet Currency Code
  *             p_cust_order_number GOE Interface Customer PO
  *   RETURN:
  *             x_agreement_id      Agreement_id   
  *   HISTORY:
  *     1.00 2012-01-11 Siman.he
  *        Generate Drp Material Plan Datas
  * =============================================*/
  PROCEDURE ADD_AGREEMENTS(P_PROJECT_ID        IN NUMBER,
                           P_CUSTOMER_ID       IN NUMBER,
                           P_ORG_ID            IN NUMBER,
                           P_AGREEMENT_NUM     IN VARCHAR2,
                           P_AGREEMENT_TYPE    IN VARCHAR2,
                           P_ALLOCATED_AMOUNT  IN NUMBER,
                           P_CURRENCY_CODE     IN VARCHAR2,
                           P_CUST_ORDER_NUMBER IN VARCHAR2,
                           P_EFFECTIVE_DATE    IN DATE DEFAULT SYSDATE,
                           P_DEBUG_FLAG        IN VARCHAR2 DEFAULT 'N',
                           X_AGREEMENT_ID      OUT NUMBER,
                           X_MSG_COUNT         OUT NUMBER,
                           X_RETURN_STATUS     OUT VARCHAR2,
                           X_MSG_DATA          OUT VARCHAR2) IS
    L_ROW_ID                VARCHAR(50);
    L_EXISTS_FLAG           NUMBER;
    L_PROJECT_FUNDING_ID    NUMBER;
    L_EMPLOYEE_EXISTS       NUMBER;
    L_OWNER_BY_PERSON_ID    NUMBER;
    L_INVPROC_CURRENCY_TYPE VARCHAR2(240);
    L_CHECK_FLAG            VARCHAR2(1);
    L_CUSTOMER_NUM          VARCHAR2(240);
    P_AGREEMENT_IN_REC      PA_AGREEMENT_PUB.AGREEMENT_REC_IN_TYPE;
    P_AGREEMENT_OUT_REC     PA_AGREEMENT_PUB.AGREEMENT_REC_OUT_TYPE;
    P_FUNDING_IN_TBL        PA_AGREEMENT_PUB.FUNDING_IN_TBL_TYPE;
    P_FUNDING_OUT_TBL       PA_AGREEMENT_PUB.FUNDING_OUT_TBL_TYPE;
  BEGIN
  
    /*  fnd_global.apps_initialize(user_id      => 1115,
                               resp_id      => 50650,
                               resp_appl_id => 275);
    mo_global.set_policy_context('S', '81');*/
  
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_DATA      := NULL;
  
    L_OWNER_BY_PERSON_ID := PA_UTILS.GETEMPIDFROMUSER(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')));
    -- Check Agreement Exist Falg
    BEGIN
      SELECT PAA.AGREEMENT_ID
        INTO X_AGREEMENT_ID
        FROM PA_AGREEMENTS PAA
       WHERE PAA.AGREEMENT_NUM = P_AGREEMENT_NUM
         AND PAA.CUSTOMER_ID = P_CUSTOMER_ID
         AND ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        X_AGREEMENT_ID := NULL;
    END;
  
    -- Agreement have exist in sysdate ,can not insert agreement
    IF X_AGREEMENT_ID IS NOT NULL THEN
      RETURN;
    END IF;
  
    -- Check owner by person id 
    SELECT COUNT(PERSON_ID)
      INTO L_EMPLOYEE_EXISTS
      FROM PA_EMPLOYEES
     WHERE PERSON_ID = L_OWNER_BY_PERSON_ID;
  
    IF L_EMPLOYEE_EXISTS = 0 THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_DATA      := L_OWNER_BY_PERSON_ID || ' can not relate employee';
    END IF;
    -- Check customer id 
    IF X_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
      L_CUSTOMER_NUM := NULL;
      BEGIN
        SELECT HCA.ACCOUNT_NUMBER
          INTO L_CUSTOMER_NUM
          FROM HZ_CUST_ACCOUNTS HCA
         WHERE HCA.CUST_ACCOUNT_ID = P_CUSTOMER_ID;
      EXCEPTION
        WHEN OTHERS THEN
          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          X_MSG_DATA      := 'Customer id ' || P_CUSTOMER_ID ||
                             ' is not valid';
      END;
    END IF;
    /* Calling Agreement Creation main program */
    P_AGREEMENT_IN_REC := NULL;
    P_FUNDING_IN_TBL.DELETE;
    X_AGREEMENT_ID := NULL;
    IF X_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
      -- Call api to create agreement 
    
      SELECT PA_AGREEMENTS_S.NEXTVAL
        INTO P_AGREEMENT_IN_REC.AGREEMENT_ID
        FROM DUAL;
    
      P_AGREEMENT_IN_REC.CUSTOMER_ID             := P_CUSTOMER_ID;
      P_AGREEMENT_IN_REC.CUSTOMER_NUM            := L_CUSTOMER_NUM;
      P_AGREEMENT_IN_REC.AGREEMENT_NUM           := P_AGREEMENT_NUM;
      P_AGREEMENT_IN_REC.AGREEMENT_TYPE          := 'Original Agreement';
      P_AGREEMENT_IN_REC.PM_AGREEMENT_REFERENCE  := P_AGREEMENT_IN_REC.AGREEMENT_NUM;
      P_AGREEMENT_IN_REC.AMOUNT                  := P_ALLOCATED_AMOUNT;
      P_AGREEMENT_IN_REC.TERM_ID                 := 4;
      P_AGREEMENT_IN_REC.REVENUE_LIMIT_FLAG      := 'N';
      P_AGREEMENT_IN_REC.OWNED_BY_PERSON_ID      := L_OWNER_BY_PERSON_ID;
      P_AGREEMENT_IN_REC.AGREEMENT_CURRENCY_CODE := P_CURRENCY_CODE;
      P_AGREEMENT_IN_REC.INVOICE_LIMIT_FLAG      := 'N';
      P_AGREEMENT_IN_REC.CUSTOMER_ORDER_NUMBER   := P_CUST_ORDER_NUMBER;
      P_AGREEMENT_IN_REC.ADVANCE_REQUIRED        := 'N';
      P_AGREEMENT_IN_REC.START_DATE              := P_EFFECTIVE_DATE;
    
      PA_AGREEMENT_PUB.CREATE_AGREEMENT(P_API_VERSION_NUMBER => 1.0,
                                        P_COMMIT             => 'F',
                                        P_INIT_MSG_LIST      => 'F',
                                        P_MSG_COUNT          => X_MSG_COUNT,
                                        P_MSG_DATA           => X_MSG_DATA,
                                        P_RETURN_STATUS      => X_RETURN_STATUS,
                                        P_PM_PRODUCT_CODE    => 'PA_PROJECT',
                                        P_AGREEMENT_IN_REC   => P_AGREEMENT_IN_REC,
                                        P_AGREEMENT_OUT_REC  => P_AGREEMENT_OUT_REC,
                                        P_FUNDING_IN_TBL     => P_FUNDING_IN_TBL,
                                        P_FUNDING_OUT_TBL    => P_FUNDING_OUT_TBL);
    
      X_AGREEMENT_ID := P_AGREEMENT_OUT_REC.AGREEMENT_ID;
    
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_DATA      := 'Calling add_agreements Occurred Error ' ||
                         SQLERRM;
  END ADD_AGREEMENTS;

  /*==================================================
  Program Name:
      copy_tasks_in_bulk
  Description:
      copy task in bulk
  History:
      1.00  2012/3/4 22:34:54  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE COPY_TASKS_IN_BULK(P_DEBUG_MODE               IN VARCHAR2 := 'N',
                               P_SRC_PROJECT_ID           IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                               P_SRC_TASK_VERSION_ID      IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                               P_SRC_STRUCTURE_VERSION_ID IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                               --   p_src_task_version_id_tbl   IN system.pa_num_tbl_type := system.pa_num_tbl_type(),
                               P_DEST_STRUCTURE_VERSION_ID IN NUMBER,
                               P_DEST_TASK_VERSION_ID      IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                               P_DEST_PROJECT_ID           IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                               P_PREFIX                    IN VARCHAR2,
                               P_PEER_OR_SUB               IN VARCHAR2 := 'PEER',
                               X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
                               X_MSG_COUNT                 OUT NOCOPY NUMBER,
                               X_MSG_DATA                  OUT NOCOPY VARCHAR2) IS
    L_API_NAME       CONSTANT VARCHAR2(30) := 'copy_tasks_in_bulk';
    L_SAVEPOINT_NAME CONSTANT VARCHAR2(30) := '';
    L_MSG_COUNT               NUMBER;
    L_MSG_DATA                VARCHAR2(100);
    L_RETURN_STATUS           VARCHAR2(100);
    L_MSG_COUNT2              NUMBER;
    L_MSG_DATA2               VARCHAR2(2000);
    L_DATA                    VARCHAR2(2000);
    L_IDX                     NUMBER;
    X_ERROR_MESSAGE           VARCHAR2(4000);
    L_SRC_TASK_VERSION_ID_TBL SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  BEGIN
    L_SRC_TASK_VERSION_ID_TBL.EXTEND;
    L_SRC_TASK_VERSION_ID_TBL(1) := P_SRC_TASK_VERSION_ID;
    LOG('copy task call procedure pa_task_pub1.copy_tasks_in_bulk');
    PA_TASK_PUB1.COPY_TASKS_IN_BULK(P_SRC_PROJECT_ID            => P_SRC_PROJECT_ID,
                                    P_SRC_STRUCTURE_VERSION_ID  => P_SRC_STRUCTURE_VERSION_ID,
                                    P_SRC_TASK_VERSION_ID_TBL   => L_SRC_TASK_VERSION_ID_TBL,
                                    P_DEST_STRUCTURE_VERSION_ID => P_DEST_STRUCTURE_VERSION_ID,
                                    P_DEST_TASK_VERSION_ID      => P_DEST_TASK_VERSION_ID,
                                    P_DEST_PROJECT_ID           => P_DEST_PROJECT_ID,
                                    P_COPY_OPTION               => 'PA_TASK_SUBTASK',
                                    P_PEER_OR_SUB               => P_PEER_OR_SUB,
                                    P_PREFIX                    => P_PREFIX,
                                    P_STRUCTURE_TYPE            => 'WORKPLAN',
                                    P_CP_DEPENDENCY_FLAG        => 'N',  --update by gusenlin 2013-01-04
                                    P_CP_DELIVERABLE_ASSO_FLAG  => 'Y',
                                    P_CP_TK_ASSIGNMENTS_FLAG    => 'Y',
                                    P_CP_PEOPLE_FLAG            => 'Y',
                                    P_CP_FINANCIAL_ELEM_FLAG    => 'Y',
                                    P_CP_MATERIAL_ITEMS_FLAG    => 'Y',
                                    P_CP_EQUIPMENT_FLAG         => 'Y',
                                    X_RETURN_STATUS             => X_RETURN_STATUS,
                                    X_MSG_COUNT                 => X_MSG_COUNT,
                                    X_MSG_DATA                  => X_MSG_DATA);
    FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
      PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                          P_MSG_INDEX     => I,
                                          P_MSG_COUNT     => X_MSG_COUNT,
                                          P_MSG_DATA      => X_MSG_DATA,
                                          P_DATA          => L_DATA,
                                          P_MSG_INDEX_OUT => L_IDX);
      X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 1000);
    END LOOP;
  END;

  /*==================================================
  Program Name:
      TASKS_ROLLUP
  Description:
      Update TASKS_ROLLUP Version
  History:
      1.00  2012/6/14 10:21:04  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE TASKS_ROLLUP(P_ELEMENT_VERSION_ID IN NUMBER,
                         X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
                         X_MSG_COUNT          OUT NOCOPY NUMBER,
                         X_MSG_DATA           OUT NOCOPY VARCHAR2) IS
    L_API_NAME       CONSTANT VARCHAR2(30) := 'Update_Schedule_Version';
    L_SAVEPOINT_NAME CONSTANT VARCHAR2(30) := '';
    X_PROJECT_ID       NUMBER;
    X_TASK_ID          NUMBER;
    L_INDEX            NUMBER;
    L_DATA             VARCHAR2(1000);
    L_ELEMENT_VERSIONS PA_NUM_1000_NUM := PA_NUM_1000_NUM(P_ELEMENT_VERSION_ID);
  BEGIN
    PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP(P_ELEMENT_VERSIONS => L_ELEMENT_VERSIONS,
                                           X_RETURN_STATUS    => X_RETURN_STATUS,
                                           X_MSG_COUNT        => X_MSG_COUNT,
                                           X_MSG_DATA         => X_MSG_DATA);
  
    FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
      PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                          P_MSG_INDEX     => I,
                                          P_MSG_COUNT     => X_MSG_COUNT,
                                          P_MSG_DATA      => X_MSG_DATA,
                                          P_DATA          => L_DATA,
                                          P_MSG_INDEX_OUT => L_INDEX);
      X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 255);
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_DATA      := 'Calling update_schedule_version Occurred Error ' ||
                         SQLERRM;
  END TASKS_ROLLUP;
  /*==================================================
  Program Name:
      Update_Schedule_Version
  Description:
      Update Schedule Version
  History:
      1.00  2012/4/19 10:21:04  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE UPDATE_SCHEDULE_VERSION(P_PEV_SCHEDULE_ID       IN NUMBER,
                                    P_RECORD_VERSION_NUMBER IN NUMBER,
                                    P_SCHEDULED_START_DATE  IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                                    P_SCHEDULED_END_DATE    IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                                    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
                                    X_MSG_COUNT             OUT NOCOPY NUMBER,
                                    X_MSG_DATA              OUT NOCOPY VARCHAR2) IS
    L_API_NAME       CONSTANT VARCHAR2(30) := 'Update_Schedule_Version';
    L_SAVEPOINT_NAME CONSTANT VARCHAR2(30) := '';
    X_PROJECT_ID NUMBER;
    X_TASK_ID    NUMBER;
    L_INDEX      NUMBER;
    L_DATA       VARCHAR2(1000);
  BEGIN
    PA_TASK_PUB1.UPDATE_SCHEDULE_VERSION(P_PEV_SCHEDULE_ID       => P_PEV_SCHEDULE_ID,
                                         P_SCHEDULED_START_DATE  => P_SCHEDULED_START_DATE,
                                         P_SCHEDULED_END_DATE    => P_SCHEDULED_END_DATE,
                                         P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
                                         X_RETURN_STATUS         => X_RETURN_STATUS,
                                         X_MSG_COUNT             => X_MSG_COUNT,
                                         X_MSG_DATA              => X_MSG_DATA);
    FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
      PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                          P_MSG_INDEX     => I,
                                          P_MSG_COUNT     => X_MSG_COUNT,
                                          P_MSG_DATA      => X_MSG_DATA,
                                          P_DATA          => L_DATA,
                                          P_MSG_INDEX_OUT => L_INDEX);
      X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 255);
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_DATA      := 'Calling update_schedule_version Occurred Error ' ||
                         SQLERRM;
  END UPDATE_SCHEDULE_VERSION;

  /*==================================================
  Program Name:
      Create_Schedule_Version
  Description:
      Create Schedule Version
  History:
      1.00  2012/4/20 10:21:04  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE CREATE_SCHEDULE_VERSION(P_ELEMENT_VERSION_ID    IN NUMBER,
                                    P_RECORD_VERSION_NUMBER IN NUMBER,
                                    P_SCHEDULED_START_DATE  IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                                    P_SCHEDULED_END_DATE    IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                                    X_PEV_SCHEDULE_ID       OUT NOCOPY NUMBER,
                                    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
                                    X_MSG_COUNT             OUT NOCOPY NUMBER,
                                    X_MSG_DATA              OUT NOCOPY VARCHAR2) IS
    L_API_NAME       CONSTANT VARCHAR2(30) := 'Update_Schedule_Version';
    L_SAVEPOINT_NAME CONSTANT VARCHAR2(30) := '';
    X_PROJECT_ID NUMBER;
    X_TASK_ID    NUMBER;
    L_INDEX      NUMBER;
    L_DATA       VARCHAR2(1000);
  BEGIN
    PA_TASK_PUB1.CREATE_SCHEDULE_VERSION(P_SCHEDULED_START_DATE => P_SCHEDULED_START_DATE,
                                         P_SCHEDULED_END_DATE   => P_SCHEDULED_END_DATE,
                                         P_ELEMENT_VERSION_ID   => P_ELEMENT_VERSION_ID,
                                         X_PEV_SCHEDULE_ID      => X_PEV_SCHEDULE_ID,
                                         X_RETURN_STATUS        => X_RETURN_STATUS,
                                         X_MSG_COUNT            => X_MSG_COUNT,
                                         X_MSG_DATA             => X_MSG_DATA);
    FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
      PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                          P_MSG_INDEX     => I,
                                          P_MSG_COUNT     => X_MSG_COUNT,
                                          P_MSG_DATA      => X_MSG_DATA,
                                          P_DATA          => L_DATA,
                                          P_MSG_INDEX_OUT => L_INDEX);
      X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 255);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_DATA      := 'Calling Create_Schedule_Version Occurred Error ' ||
                         SQLERRM;
  END CREATE_SCHEDULE_VERSION;
  /*==================================================
  Program Name:
      structure_published
  Description:
      structure published
  History:
      1.00  2012/5/29 15:08:00  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE STRUCTURE_PUBLISHED(P_PROJECT_ID              IN NUMBER,
                                X_PUBLISHED_STRUCT_VER_ID OUT NOCOPY NUMBER,
                                X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
                                X_MSG_COUNT               OUT NOCOPY NUMBER,
                                X_MSG_DATA                OUT NOCOPY VARCHAR2) AS
    L_STRUCTURE_VERSION_ID NUMBER;
    L_STATUS_CODE          VARCHAR2(100) := 'STRUCTURE_PUBLISHED';
    L_INDEX                NUMBER;
    L_DATA                 VARCHAR2(1000);
  BEGIN
    SELECT PA_PROJECT_STRUCTURE_UTILS.GET_CURRENT_WORKING_VER_ID(P_PROJECT_ID)
      INTO L_STRUCTURE_VERSION_ID
      FROM DUAL;
    PA_PROJECT_PUB.CHANGE_STRUCTURE_STATUS(P_RETURN_STATUS           => X_RETURN_STATUS,
                                           P_MSG_COUNT               => X_MSG_COUNT,
                                           P_MSG_DATA                => X_MSG_DATA,
                                           P_STRUCTURE_VERSION_ID    => L_STRUCTURE_VERSION_ID,
                                           P_PA_PROJECT_ID           => P_PROJECT_ID,
                                           P_STATUS_CODE             => L_STATUS_CODE,
                                           P_PROCESS_MODE            => 'ONLINE',
                                           P_PUBLISHED_STRUCT_VER_ID => X_PUBLISHED_STRUCT_VER_ID);
    FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
      PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                          P_MSG_INDEX     => I,
                                          P_MSG_COUNT     => X_MSG_COUNT,
                                          P_MSG_DATA      => X_MSG_DATA,
                                          P_DATA          => L_DATA,
                                          P_MSG_INDEX_OUT => L_INDEX);
      X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 255);
    END LOOP;
  END;
  /*==================================================
  Program Name:
      update_task_assignments
  Description:
      update task assignments
  History:
      1.00  2012/5/29 15:08:00  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE UPDATE_TASK_ASSIGNMENTS(P_PROJECT_ID         IN NUMBER,
                                    P_PLANNED_QUANTITY   IN NUMBER,
                                    P_TASK_ASSIGNMENT_ID IN NUMBER,
                                    X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
                                    X_MSG_COUNT          OUT NOCOPY NUMBER,
                                    X_MSG_DATA           OUT NOCOPY VARCHAR2) AS
    L_STRUCTURE_VERSION_ID NUMBER;
    L_STATUS_CODE          VARCHAR2(100) := 'STRUCTURE_PUBLISHED';
    L_INDEX                NUMBER;
    L_DATA                 VARCHAR2(1000);
    P_TASK_ASSIGNMENTS_IN  PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_IN_TBL_TYPE;
    P_TASK_ASSIGNMENTS_OUT PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_OUT_TBL_TYPE;
  BEGIN
    SELECT PA_PROJECT_STRUCTURE_UTILS.GET_CURRENT_WORKING_VER_ID(P_PROJECT_ID)
      INTO L_STRUCTURE_VERSION_ID
      FROM DUAL;
    P_TASK_ASSIGNMENTS_IN(1).PLANNED_QUANTITY := P_PLANNED_QUANTITY;
    P_TASK_ASSIGNMENTS_IN(1).PA_TASK_ASSIGNMENT_ID := P_TASK_ASSIGNMENT_ID;
    P_TASK_ASSIGNMENTS_IN(1).BURD_COST_RATE_OVERRIDE := 1;
  
    PA_TASK_ASSIGNMENTS_PUB.UPDATE_TASK_ASSIGNMENTS(P_API_VERSION_NUMBER      => 1.0,
                                                    P_PM_PRODUCT_CODE         => 'pjm',
                                                    P_PA_PROJECT_ID           => P_PROJECT_ID,
                                                    P_PA_STRUCTURE_VERSION_ID => L_STRUCTURE_VERSION_ID,
                                                    P_TASK_ASSIGNMENTS_IN     => P_TASK_ASSIGNMENTS_IN,
                                                    P_TASK_ASSIGNMENTS_OUT    => P_TASK_ASSIGNMENTS_OUT,
                                                    X_MSG_COUNT               => X_MSG_COUNT,
                                                    X_MSG_DATA                => X_MSG_DATA,
                                                    X_RETURN_STATUS           => X_RETURN_STATUS);
    FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
      PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                          P_MSG_INDEX     => I,
                                          P_MSG_COUNT     => X_MSG_COUNT,
                                          P_MSG_DATA      => X_MSG_DATA,
                                          P_DATA          => L_DATA,
                                          P_MSG_INDEX_OUT => L_INDEX);
      X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 255);
    END LOOP;
  END;

  /*==================================================
  Program Name:
      Update_Structure_Version_Attr
  Description:
      update Structure Version_Attr
  History:
      1.00  2012/7/24 15:08:00  ouzhiwei  Creation
  ==================================================*/
  PROCEDURE Update_Structure_Version_Attr(p_pev_structure_id       IN NUMBER,
                                          p_structure_version_name IN NUMBER,
                                          p_record_version_number  IN NUMBER,
                                          X_RETURN_STATUS          OUT NOCOPY VARCHAR2,
                                          X_MSG_COUNT              OUT NOCOPY NUMBER,
                                          X_MSG_DATA               OUT NOCOPY VARCHAR2) AS
  
    L_INDEX NUMBER;
    L_DATA  VARCHAR2(1000);
  BEGIN
    PA_PROJECT_STRUCTURE_PUB1.Update_Structure_Version_Attr(p_validate_only              => 'F',
                                                            p_pev_structure_id           => p_pev_structure_id,
                                                            p_locked_status_code         => 'LOCKED',
                                                            p_struct_version_status_code => 'STRUCTURE_WORKING',
                                                            p_baseline_current_flag      => 'N',
                                                            p_baseline_original_flag     => 'N',
                                                            p_structure_version_name     => p_structure_version_name,
                                                            p_structure_version_desc     => NULL,
                                                            p_record_version_number      => p_record_version_number,
                                                            p_change_reason_code         => NULL,
                                                            x_return_status              => x_return_status,
                                                            x_msg_count                  => x_msg_count,
                                                            x_msg_data                   => x_msg_data);
    FOR I IN 1 .. NVL(X_MSG_COUNT, 0) LOOP
      PA_INTERFACE_UTILS_PUB.GET_MESSAGES(P_ENCODED       => 'F',
                                          P_MSG_INDEX     => I,
                                          P_MSG_COUNT     => X_MSG_COUNT,
                                          P_MSG_DATA      => X_MSG_DATA,
                                          P_DATA          => L_DATA,
                                          P_MSG_INDEX_OUT => L_INDEX);
      X_MSG_DATA := SUBSTRB(X_MSG_DATA || L_DATA, 1, 255);
    END LOOP;
  END;

END XXPA_PROJ_PUBLIC_PVT;
/
