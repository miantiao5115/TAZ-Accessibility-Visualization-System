package online.miantiao.controller;


import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import online.miantiao.Entity.ResultMessage;
import online.miantiao.Entity.TAZAccessibilityInfo;
import online.miantiao.service.CalculateServiceImpl;

@Controller
public class SysController {
	
	private static final int SUCCESSCODE=200;
	
	private static final int FAILCODE=400; 
	
	@Autowired
	private CalculateServiceImpl service;
	
	/**
	  *  将上传的文件转换为json
	 * @param tazAccessibilityFile 交通分析区 可达性excel文件
	 * @return
	 */
	@RequestMapping(value="/parseExcel")
	@ResponseBody
	public ResultMessage calculate(@RequestParam(value = "tazAccessibilityFile") MultipartFile tazAccessibilityFile) {
		
		ResultMessage resultMessage = new ResultMessage();
		
		if (tazAccessibilityFile == null) {
			System.out.println("交通分析区 网可达性数据文件上传失败");
			resultMessage.setCode(FAILCODE);
			resultMessage.setMsg("交通分析区 网可达性数据文件上传失败");
			return resultMessage;
		}
		
		// 交通分析区 可达性数据文件名
		String tazAccessibilityFileName = tazAccessibilityFile.getOriginalFilename();
		
		// 交通分析区 可达性数据文件大小
		long tazAccessibilityFileSize=tazAccessibilityFile.getSize();
		
		//进一步判断文件是否为空（即判断其大小是否为0或其名称是否为null）验证文件名是否合格
		if(tazAccessibilityFileName==null || ("").equals(tazAccessibilityFileName) ||!service.isExcelFile(tazAccessibilityFileName)){
            System.out.println("交通分析区可达性数据文件为空或文件格式不正确！请使用完整的.xls或.xlsx后缀文档。");
            resultMessage.setCode(FAILCODE);
			resultMessage.setMsg("交通分析区可达性数据文件为空或文件格式不正确！请使用完整的.xls或.xlsx后缀文档。");
			return resultMessage;
        }
		
        //解析可达性excel，获取交通分析区 可达性信息集合。
        List<TAZAccessibilityInfo> tazAccessibilityInfoList = service.readTAZAccessibilityExcelFile(tazAccessibilityFile);
        if(tazAccessibilityInfoList == null ) {
        	System.out.println("交通分析区可达性数据文件内容为空");
        	resultMessage.setCode(FAILCODE);
    		resultMessage.setMsg("交通分析区可达性数据文件内容为空");
    		return resultMessage;
        }
        System.out.println("交通分析区个数:"+tazAccessibilityInfoList.size());
        
		resultMessage.setCode(SUCCESSCODE);
		resultMessage.setMsg("解析成功");
		return resultMessage.add("tazAccessibilityInfoList", tazAccessibilityInfoList);
	}
}
