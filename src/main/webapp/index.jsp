<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%
	pageContext.setAttribute("BASE_PATH", request.getContextPath());
%>
<meta charset="utf-8" />
<title>交通分析区可达性可视化系统</title>
<style>
html, body, #viewDiv {
	padding: 0;
	margin: 0;
	height: 100%;
	width: 100%;
}

#infoWindow {
	right: 15px;
	margin: 0 auto;
	margin-right: 5px;
	position: absolute;
	top: 5em;
	z-index: 99;
}

#uploadForm {
	display: block;
	padding: 0.1em;
}
</style>
<link rel="shortcut icon" href="${BASE_PATH}/static/img/map.ico">
<link rel="stylesheet"
	href="http://39.106.31.176:8080/arcgis_js_api/4.14/esri/themes/light/main.css" />
<script src="http://39.106.31.176:8080/arcgis_js_api/4.14/init.js"></script>
<link href="${BASE_PATH}/static/css/bootstrap.min.css" rel="stylesheet">
<link href="${BASE_PATH}/static/css/font-awesome.css" rel="stylesheet">
<link href="${BASE_PATH}/static/css/style.css" rel="stylesheet">

<script>
    require([
      "esri/config",
      "esri/Map",
      "esri/views/MapView",
      "esri/widgets/Expand",
      "esri/request",
      "esri/widgets/Legend",
      "esri/layers/FeatureLayer",
      "esri/layers/support/Field",
      "esri/Graphic"
    ], function (
      esriConfig,
      Map,
      MapView,
      Expand,
      request,
      Legend,
      FeatureLayer,
      Field,
      Graphic
    ) {
	  //定义可达性数据变量
      var accessibilityInfoList;
      /*****************************************************************
             * 为渲染器定义每一级的渲染颜色.
       *****************************************************************/
      var less10 = {
        type: "simple-fill", 
        color: [245, 245, 0],
        style: "solid",
        outline: {
          width: 0.2,
          color: [255, 255, 255, 0.5]
        }
      };

      var less20 = {
        type: "simple-fill", 
        color: [245, 216, 0],
        style: "solid",
        outline: {
          width: 0.2,
          color: [255, 255, 255, 0.5]
        }
      };

      var less30 = {
        type: "simple-fill", 
        color: [245, 188, 0],
        style: "solid",
        outline: {
          width: 0.2,
          color: [255, 255, 255, 0.5]
        }
      };

      var less40 = {
        type: "simple-fill", 
        color: [245, 163, 0],
        style: "solid",
        outline: {
          width: 0.2,
          color: [255, 255, 255, 0.5]
        }
      };

      var less50 = {
        type: "simple-fill", 
        color: [245, 135, 0],
        style: "solid",
        outline: {
          width: 0.2,
          color: [255, 255, 255, 0.5]
        }
      };

      var less60 = {
        type: "simple-fill", 
        color: [245, 106, 0],
        style: "solid",
        outline: {
          width: 0.2,
          color: [255, 255, 255, 0.5]
        }
      };

      var less70 = {
        type: "simple-fill", 
        color: [245, 82, 0],
        style: "solid",
        outline: {
          width: 0.2,
          color: [255, 255, 255, 0.5]
        }
      };

      var less80 = {
        type: "simple-fill", 
        color: [245, 53, 0],
        style: "solid",
        outline: {
          width: 0.2,
          color: [255, 255, 255, 0.5]
        }
      };

      var less90 = {
        type: "simple-fill", 
        color: [245, 24, 0],
        style: "solid",
        outline: {
          width: 0.2,
          color: [255, 255, 255, 0.5]
        }
      };

      var more90 = {
        type: "simple-fill", 
        color: [245, 0, 0],
        style: "solid",
        outline: {
          width: 0.2,
          color: [255, 255, 255, 0.5]
        }
      };

      /*****************************************************************
            * 分层设色渲染器
            * 总共分为10级
      *****************************************************************/
      const renderer = {
        type: "class-breaks", 
        field: "ACC",
        defaultSymbol: {
          type: "simple-fill", 
          color: "black",
          style: "backward-diagonal",
          outline: {
            width: 0.5,
            color: [50, 50, 50, 0.6]
          }
        },
        defaultLabel: "no data",
        classBreakInfos: [
          {
            minValue: 0,
            maxValue: 10,
            symbol: less10,
            label: "< 10"
          },
          {
            minValue: 10,
            maxValue: 20,
            symbol: less20,
            label: "10 -20"
          },
          {
            minValue: 20,
            maxValue: 30,
            symbol: less30,
            label: "20-30"
          },
          {
            minValue: 30,
            maxValue: 40,
            symbol: less40,
            label: "30-40"
          },
          {
            minValue: 20,
            maxValue: 30,
            symbol: less50,
            label: "40-50"
          },
          {
            minValue: 20,
            maxValue: 30,
            symbol: less60,
            label: "50-60"
          },
          {
            minValue: 20,
            maxValue: 30,
            symbol: less70,
            label: "60-70"
          },
          {
            minValue: 20,
            maxValue: 30,
            symbol: less80,
            label: "70-80"
          },
          {
            minValue: 80,
            maxValue: 90,
            symbol: less90,
            label: "80-90"
          },
          {
            minValue: 90,
            maxValue: 200,
            symbol: more90,
            label: ">90"
          }

        ]
      };
      
      //arcgis门户
      var portalUrl = "https://www.arcgis.com";
      
      //添加底图
      var map = new Map({
        basemap: "gray"
      });

      //定义视图
      var view = new MapView({
        center: [114.185954994, 22.6632718492],
        zoom: 3,
        map: map,
        container: "viewDiv",
        popup: {
          defaultPopupTemplateEnabled: true
        }
      });


      /******************************************************************
       *
             * 添加图例至整个视图的左下方
       *
      ******************************************************************/
      const legend = new Legend({
        view: view
      });

      view.ui.add(legend, "bottom-left");

      /*
             *解析上载的shapefile文件
       */
      function generateFeatureCollection(fileName) {
        var name = fileName.split(".");
        
        name = name[0].replace("c:\\miantiao\\", "");
        
        var params = {
          name: name,
          targetSR: view.spatialReference,
          maxRecordCount: 1000,
          enforceInputFileSizeLimit: true,
          enforceOutputJsonSizeLimit: true
        };

        params.generalize = true;
        params.maxAllowableOffset = 10;
        params.reducePrecision = true;
        params.numberOfDigitsAfterDecimal = 0;

        var myContent = {
          filetype: "shapefile",
          publishParameters: JSON.stringify(params),
          f: "json"
        };

        // 调用arcgis在线解析shapefile文件的gp工具
        request(portalUrl + "/sharing/rest/content/features/generate", {
          query: myContent,
          body: document.getElementById("uploadForm"),
          responseType: "json"
        })
          .then(function (response) {
            var layerName =
              response.data.featureCollection.layers[0].layerDefinition.name;
            console.log("获取到shapefile数据文件的所有feature集合......");
            $("#prog").css("width","50%").text("50%");
            addShapefileToMap(response.data.featureCollection);
          })
          .catch(errorHandler);
      }

      function errorHandler(error) {
        $("#infoModal").modal('hide');
        $("#prompt_info").html("shapefile文件加载失败，失败原因：" + error.message);
        $("#warningModal").modal('show');
      }

       /*
              *添加featurelayer到地图中
        */
      function addShapefileToMap(featureCollection) {
        var sourceGraphics = [];

        var layers = featureCollection.layers.map(function (layer) {
          var graphics = layer.featureSet.features.map(function (feature) {

		    feature.attributes.ACC = accessibilityInfoList[feature.attributes.FID].accessibility;
            return Graphic.fromJSON(feature);
          });
          sourceGraphics = sourceGraphics.concat(graphics);
          var featureLayer = new FeatureLayer({
            objectIdField: "FID",
            renderer: renderer,
            source: graphics,
            fields: layer.layerDefinition.fields.map(function (field) {
              return Field.fromJSON(field);
            })
          });
          return featureLayer;
        });
        map.addMany(layers);
        console.log("成功将所有feature添加到地图中......");
        $("#prog").css("width","80%").text("80%");
        view.goTo(sourceGraphics);
        console.log("前往地图区域......");
        $("#prog").css("width","90%").text("90%");
        console.log("解析成功......");
        $("#prog").css("width","100%").text("100%");
        $("#infoModal").modal('hide');
      }
      
      /*
             *解析可达性数据的Excel文件
       */
      function parseExcel(){
    	
    	console.log("开始解析可达性数据文件......");
        $("#prog").css("width","10%").text("10%");
          
      	var formData = new FormData();
	  	formData.append("tazAccessibilityFile",$("#accessibilityFileName")[0].files[0]);
	    console.log(formData);
    	$.ajax({
            url:"${BASE_PATH}/parseExcel",
            type:"POST",
            data :formData,
            contentType: false,
            async: false,
            cache: false, 
            processData: false, 
            contentType: false,
            success:function (data) {
            	if(data.code == 200){
            		accessibilityInfoList = data.resultMap.tazAccessibilityInfoList;
                    console.log("解析可达性数据文件成功......");
                    $("#prog").css("width","20%").text("20%");
            	} 
            	if(data.code == 400){
            		$("#infoModal").modal('hide');
                    $("#prompt_info").html("可达性数据文件加载失败，失败原因：" + data.msg);
                    $("#warningModal").modal('show');
            	}
            	
            },
            error:function(XMLHttpRequest, textStatus, errorThrown){
            	$("#infoModal").modal('hide');
                $("#prompt_info").html("可达性数据文件加载失败，失败原因：" + textStatus);
                $("#warningModal").modal('show');
            }
    	});
      }
      /*
             * 获取文件名
       */
      function getFileName(file){
        var pos=file.lastIndexOf("\\");
        return file.substring(pos+1); 
      }

      //数据上载按钮点击事件
      $("#upload_files_btn").click(function () {
          //清除表单数据（表单重置）
          $("#uploadFilesModel form")[0].reset();
          //弹出模态框
          $("#uploadFilesModel").modal({
              backdrop: "static"
          });
      });
      
      //使用说明按钮点击事件
      $("#introduction_btn").click(function () {
          //弹出模态框
          $("#introductionModal").modal({
              backdrop: "static"
          });
      });

      //数据上载模态框中确定按钮点击事件
      $("#start").click(function () {
        
        var shapeFileName = getFileName($("#inFileOfShapefile").val());
        var accessibilityFileName = getFileName($("#accessibilityFileName").val());
        //检查shapefile文件的格式
        if (shapeFileName.indexOf(".zip") == -1) {
          $("#prompt_info").html('添加的shapefile文件必须是以.zip为扩展名的压缩文件');
          $("#warningModal").modal('show');
          console.log("添加的shapefile文件必须是以.zip为扩展名的压缩文件");
          return;
        }
        //检查可达性数据文件的格式
        if (accessibilityFileName.indexOf(".xlsx") == -1 && accessibilityFileName.indexOf(".xls") == -1) {
          $("#prompt_info").html('添加的可达性数据文件必须是以.xlsx或.xls为扩展名的Excle文件');
          $("#warningModal").modal('show');
          console.log("添加的可达性数据文件必须是以.xlsx或.xls为扩展名的Excle文件");
          return;
        }
        //关闭数据上载模态框
        $("#uploadFilesModel").modal('hide');
        
        //打开加载进度条模态框
        $("#infoModal").modal('show');
       
        //解析可达性数据文件
        parseExcel();
       
        console.log("开始解析shapefile数据文件......");
        $("#prog").css("width","30%").text("30%");
        
        //开始解析shapefile文件
        generateFeatureCollection(shapeFileName);
        
      });
    });
  </script>
</head>

<body>
	<div id="viewDiv">
		<div id="infoWindow" class="ibox float-e-margins"
			style="width: 220px; height: 140px;">
			<div class="ibox-title">
				<h5>交通分析区可达性可视化系统</h5>
			</div>
			<div class="ibox-content">
				<button id="upload_files_btn" class="btn"
					style="width: 180px; height: 40px;">数据上载</button>
				<button id="introduction_btn" class="btn"
					style="width: 180px; height: 40px;">使用说明</button>
			</div>
		</div>
	</div>
	<!--数据上载模态框-->
	<div class="modal fade" id="uploadFilesModel" tabindex="5"
		role="dialog" aria-labelledby="myModalLabel">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-label="Close">
						<span aria-hidden="true">&times;</span>
					</button>
					<font size="4px">数据上载</font>
				</div>
				<div class="modal-body">
					<div style="padding-left: 4px;">
						<p>添加shapefile的压缩包文件，生成相应地图.</p>
						<form enctype="multipart/form-data" method="post" id="uploadForm">
							<div class="field">
								<label class="file-upload"> <input type="file"
									name="file" id="inFileOfShapefile" />
								</label>
							</div>
						</form>
					</div>
					<div style="padding-left: 4px;">
						<p>添加Excel格式的可达性数据文件.</p>
						<form enctype="multipart/form-data" method="post">
							<div class="field">
								<label class="file-upload"> <input type="file"
									name="file" id="accessibilityFileName" />
								</label>
							</div>
						</form>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="start">确定</button>
				</div>
			</div>
		</div>
	</div>
	<!--使用说明模态框-->
	<div class="modal fade" id="introductionModal" tabindex="-1"
		role="dialog" aria-labelledby="myModalLabel">
		<div class="modal-dialog" role="document"
			style='position: relative;'>
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-label="Close">
						<span aria-hidden="true">&times;</span>
					</button>
					<font size="4px">使用说明</font>
				</div>
				<div class="modal-body">
					<div>
						<!-- 导航栏 -->
						<ul class="nav nav-tabs" role="tablist">
							<li role="presentation" class="active"><a href="#about"
								aria-controls="home" role="tab" data-toggle="tab">关于该系统</a></li>
							<li role="presentation"><a href="#shapefile"
								aria-controls="profile" role="tab" data-toggle="tab">shapefile文件格式说明</a></li>
							<li role="presentation"><a href="#accessibilityData"
								aria-controls="messages" role="tab" data-toggle="tab">可达性数据格式说明</a></li>
						</ul>
						<!-- 详情 -->
						<div class="tab-content">
							<div role="tabpanel" class="tab-pane active" id="about">
								<br>
								这是一个主要用于可视化交通分析区的可达性（可以是公交可达性、步行可达性、机会可达性等等）简单web应用。在实现过程中，调用了ArcGIS
								REST API来解析shapefile文件，同时在后端使用Apache
								POI工具解析Excel数据文件。您可以使用我提供的实例数据来体验该web应用的功能。该应用是我个人的一个练手小项目，技术比较拙劣，还请指教，同时欢迎来踩我的<a
									href="https://miantiao.online/">博客</a>。
							</div>
							<div role="tabpanel" class="tab-pane" id="shapefile">
								<br>
								在该应用中，shapefile文件必须以.zip格式的压缩包文件上传，主要用于构建地图的features。shapefile文件可以包含多个属性字段，其中FID和ACC是两个必需要字段，若缺失这两个字段，将无法解析。<a
									href="http://miantiao.online:8080/bulisiban.zip">点击这里</a>下载shapefile示例数据。
							</div>
							<div role="tabpanel" class="tab-pane" id="accessibilityData">
								<br>
								可达性数据文件必须以Excel(.xls或.xlsx)文件格式上传。可达性数据文件只能包含两个属性字段，其中第一个属性字段必须与shapefile文件的FID一一对应；第二个属性字段是可达性数值，其数据类型必须是数字；除此之外Excel文件的第一行必须是字段名称行。<a
									href="http://miantiao.online:8080/accessibility.xlsx">点击这里</a>下载可达性示例数据。
							</div>
						</div>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
				</div>
			</div>
		</div>
	</div>
	<!--处理进程模态框-->
	<div class="modal fade" id="infoModal" tabindex="-1" role="dialog"
		aria-labelledby="myModalLabel">
		<div class="modal-dialog" role="document"
			style='position: relative; top: 30%;'>
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-label="Close">
						<span aria-hidden="true">&times;</span>
					</button>
					<font size="4px">正在解析，请稍后！</font>
				</div>
				<div class="modal-body">
					<div class="progress progress-striped active">
						<div id="prog" class="progress-bar progress-bar-animated"
							role="progressbar" aria-valuenow="" aria-valuemin="0"
							aria-valuemax="100" style="width: 0%;">0%</div>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
				</div>
			</div>
		</div>
	</div>
	<!-- 提示模态框 -->
	<div class="modal fade" id="warningModal" tabindex="-1" role="dialog"
		aria-labelledby="myModalLabel">
		<div class="modal-dialog" role="document"
			style='position: relative; top: 30%;'>
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-label="Close">
						<span aria-hidden="true">&times;</span>
					</button>
					<font size="4px">温馨提示</font>
				</div>
				<div class="modal-body">
					<img src="${BASE_PATH}/static/img/message.png" alt="Smiley face"
						width="42" height="42">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font
						id="prompt_info" size="2px"></font>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
				</div>
			</div>
		</div>
	</div>
	<script src="${BASE_PATH}/static/js/jquery.min.js"></script>
	<script src="${BASE_PATH}/static/js/bootstrap.min.js"></script>
</body>

</html>