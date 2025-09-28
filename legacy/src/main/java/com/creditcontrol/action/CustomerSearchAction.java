package com.creditcontrol.action;

import java.util.ArrayList;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import com.creditcontrol.form.CustomerSearchForm;
import com.creditcontrol.model.Customer;
import com.creditcontrol.util.LoggerUtil;

/**
 * Customer Search Action - Struts Action (POC Implementation)
 */
public class CustomerSearchAction extends Action {
    
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm form,
                               HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        CustomerSearchForm searchForm = (CustomerSearchForm) form;
        ActionMessages messages = new ActionMessages();
        
        try {
            LoggerUtil.logAudit("SYSTEM", "CUSTOMER_SEARCH", "CustomerSearchPage", "ACCESSED");
            
            String submitAction = request.getParameter("action");
            if ("search".equals(submitAction)) {
                return performSearch(mapping, searchForm, request, messages);
            } else {
                prepareSearchPage(request);
                return mapping.findForward("success");
            }
            
        } catch (Exception e) {
            LoggerUtil.logSystemError(CustomerSearchAction.class, "Error in customer search", e);
            return mapping.findForward("error");
        }
    }
    
    private ActionForward performSearch(ActionMapping mapping, CustomerSearchForm searchForm,
                                      HttpServletRequest request, ActionMessages messages) {
        
        // 模拟搜索结果 (POC)
        List<Customer> searchResults = createMockSearchResults();
        
        request.setAttribute("searchResults", searchResults);
        request.setAttribute("searchSummary", "Found " + searchResults.size() + " customers");
        
        LoggerUtil.logBusiness("CustomerSearch", "Search completed: " + searchResults.size() + " results");
        
        prepareSearchPage(request);
        return mapping.findForward("success");
    }
    
    private List<Customer> createMockSearchResults() {
        List<Customer> results = new ArrayList<>();
        
        Customer customer1 = new Customer();
        customer1.setCustomerCode("CUST001");
        customer1.setCompanyName("ABC Manufacturing Ltd");
        customer1.setContactPerson("John Smith");
        customer1.setIndustry("Manufacturing");
        customer1.setPhone("555-0101");
        customer1.setStatus("ACTIVE");
        results.add(customer1);
        
        Customer customer2 = new Customer();
        customer2.setCustomerCode("CUST002");
        customer2.setCompanyName("XYZ Trading Corp");
        customer2.setContactPerson("Jane Doe");
        customer2.setIndustry("Trading");
        customer2.setPhone("555-0102");
        customer2.setStatus("ACTIVE");
        results.add(customer2);
        
        return results;
    }
    
    private void prepareSearchPage(HttpServletRequest request) {
        List<String> industries = new ArrayList<>();
        industries.add("Manufacturing");
        industries.add("Trading");
        industries.add("Logistics");
        industries.add("Technology");
        
        request.setAttribute("industries", industries);
        request.setAttribute("currentTime", new java.util.Date());
    }
}
