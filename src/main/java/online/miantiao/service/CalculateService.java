package online.miantiao.service;

import java.util.HashMap;
import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import online.miantiao.Entity.TAZAccessibilityInfo;


public interface CalculateService {

	/**
	 * 检查文件是否是excel文件
	 * @param fileName 文件名
	 * @return
	 */
	public boolean isExcelFile(String fileName);
	
	/**
	  * 读取交通分析区可达性的excel文件内容
	 * @param Mfile 上载的文件
	 * @return
	 */
	public List<TAZAccessibilityInfo> readTAZAccessibilityExcelFile(MultipartFile Mfile); 


}
