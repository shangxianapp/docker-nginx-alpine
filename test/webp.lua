function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
 end
 
 local newFile = ngx.var.request_filename;
 local originalFile = newFile:sub(1, #newFile - 5); -- 去掉 .webp 的后缀
 
 if not file_exists(originalFile) then -- 原文件不存在
   ngx.exit(404);
   return;
 end
 
 os.execute("cwebp -q 75 " .. originalFile  .. " -o " .. newFile);   -- 转换原图片到 webp 格式，这里的质量是 75 ，你也可以改成别的
 
 if file_exists(newFile) then -- 如果新文件存在（转换成功）
     ngx.exec(ngx.var.uri) -- Internal Redirect
 else
     ngx.exit(404)
 end