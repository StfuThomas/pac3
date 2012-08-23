local PART = {}

PART.ClassName = "material"
PART.NonPhysical = true

PART.ShaderParams =
{
	BaseTexture = "ITexture",
	
	CloakPassEnabled  = "boolean",
	CloakFactor = "number",
	--CloakColorTint = "Vector",
	RefractAmount = "number",
	
	BumpMap = "ITexture",
	LightWarpTexture = "ITexture",

	Detail = "ITexture",
	DetailTint = "Vector",
	DetailScale = "number",
	DetailBlendMode = "number",
	DetailBlendFactor = "number",
	
	Phong = "boolean",
	PhongBoost = "number",
	PhongExpontent = "number",
	PhongTint = "Vector",
	PhongFresnelRanges = "Vector",
	PhongWarpTexture = "ITexture",
	PhongAlbedoTint = "boolean",
	PhongExponentTexture = "ITexture",
	
	Rimlight = "boolean",	
	RimlightBoost = "number",	
	RimlightExponent = "number",
	
	EnvMap = "ITexture",
	EnvMapMask = "ITexture",
	EnvMapTint = "Vector",
	EnvMapContrast = "number",
	EnvMapSaturation = "Vector",
	EnvMapMode = "number",
	
	--[[EmissiveBlendEnabled = "boolean",
	EmissiveBlendTexture = "ITexture",
	EmissiveBlendBaseTexture = "ITexture",
	EmissiveBlendFlowTexture = "ITexture",
	EmissiveBlendTint = "Vector",
	EmissiveBlendScrollVector = "Vector",
	
	HalfLambert = "boolean",]]
}

function PART:Think()
	if self.delay_set and self.Parent then
		self.delay_set()
		self.delay_set = nil
	end
end

local function setup(PART)
	for name, T in pairs(PART.ShaderParams) do		
		if T == "ITexture" then
			pac.GetSet(PART, name, "")

			PART["Set" .. name] = function(self, var)
				self[name] = var
								
				if 
					self.SKIP or
					pac.HandleUrlMat(
						self, 
						var, 
						function(_, tex) 
							local mat = self:GetMaterialFromParent()
							if mat then
								if VERSION >= 150 then
									mat:SetTexture("$" .. name, tex)
								else
									mat:SetMaterialTexture("$" .. name, tex)
								end
								self.SKIP = true
								self:UpdateMaterial()
								self.SKIP = false
							else
								self.delay_set = function()
									local mat = self:GetMaterialFromParent()
									if mat then
										if VERSION >= 150 then
											mat:SetTexture("$" .. name, tex)
										else
											mat:SetMaterialTexture("$" .. name, tex)
										end
										self.SKIP = true
										self:UpdateMaterial()
										self.SKIP = false
									end
								end
							end
						end
					)
				then
					return
				end
				
				local mat = self:GetMaterialFromParent()
				
				if mat then				
					if var ~= "" then
						local _mat = Material(var)
						local tex
						
						if VERSION >= 150 then
							tex = _mat:GetTexture("$" .. name) 
						else
							tex = _mat:GetMaterialTexture("$" .. name)
						end
						
						if not tex or tex:IsError() then
							if VERSION >= 150 then
								tex = CreateMaterial("pac3_tex_" .. var .. "_" .. self.Id, "VertexLitGeneric", {["$basetexture"] = var}):GetTexture("$basetexture")
							else
								tex = CreateMaterial("pac3_tex_" .. var .. "_" .. self.Id, "VertexLitGeneric", {["$basetexture"] = var}):GetMaterialTexture("$basetexture")
							end
							if not tex or tex:IsError() then
								if VERSION >= 150 then
									tex = _mat:GetTexture("$basetexture")
								else
									tex = _mat:GetMaterialTexture("$basetexture")
								end
							end
						end
						
						if VERSION >= 150 then
							mat:SetTexture("$" .. name, tex)
						else
							mat:SetMaterialTexture("$" .. name, tex)
						end
					else
						if name == "BumpMap" then
							if VERSION >= 150 then
								mat:SetString("$bumpmap", "dev/bump_normal")
							else
								mat:SetMaterialString("$bumpmap", "dev/bump_normal")
							end
						end
					end
				end
			end
		elseif T == "boolean" then	
			pac.GetSet(PART, name, false)
			
			PART["Set" .. name] = function(self, var)
				self[name] = var
				
				local mat = self:GetMaterialFromParent()
				
				if mat then
					if VERSION >= 150 then
						mat:SetInt("$" .. name, var and 1 or 0)
					else
						mat:SetMaterialInt("$" .. name, var and 1 or 0)
					end
				end
			end
		elseif T == "number" then
			pac.GetSet(PART, name, 0)
			
			PART["Set" .. name] = function(self, var)
				self[name] = var
				
				local mat = self:GetMaterialFromParent()
				
				if mat then
					if VERSION >= 150 then
						mat:SetFloat("$" .. name, var)
					else
						mat:SetMaterialFloat("$" .. name, var)
					end
				end
			end
		elseif T == "Vector" then
			pac.GetSet(PART, name, Vector(0,0,0))
			
			PART["Set" .. name] = function(self, var)
				self[name] = var
				
				local mat = self:GetMaterialFromParent()
				
				if mat then
					if VERSION >= 150 then
						mat:SetVector("$" .. name, var)
					else
						mat:SetMaterialVector("$" .. name, var)
					end
				end
			end
		end
	end
end

pac.StartStorableVars()
	setup(PART)
pac.EndStorableVars()


function PART:GetMaterialFromParent()
	if self.Parent:IsValid() then
		--print(self.Materialm and self.Materialm:GetName(), self.Parent.Materialm:GetName(), self.last_mat and self.last_mat:GetName())
		if not self.Materialm then
			local mat = CreateMaterial("pac_material_" .. SysTime(), "VertexLitGeneric", {})
			
			if self.Parent.Materialm then
				local tex
				if VERSION >= 150 then
					tex = self.Parent.Materialm:GetTexture("$bumpmap")
				else
					tex = self.Parent.Materialm:GetMaterialTexture("$bumpmap")
				end
				if tex and not tex:IsError() then
					if VERSION >= 150 then
						mat:SetTexture("$bumpmap", tex)
					else
						mat:SetMaterialTexture("$bumpmap", tex)
					end
				end
				
				local tex
				if VERSION >= 150 then
					tex = self.Parent.Materialm:GetTexture("$basetexture")
				else
					tex = self.Parent.Materialm:GetMaterialTexture("$basetexture")
				end
				if tex and not tex:IsError() then
					if VERSION >= 150 then
						mat:SetTexture("$basetexture", tex)
					else
						mat:SetMaterialTexture("$basetexture", tex)
					end
				end
			end
			
			self.Materialm = mat
		end
		
		self.Parent.Materialm = self.Materialm
		
		return self.Materialm
	end
end

function PART:OnParent(parent)
	self:GetMaterialFromParent()
end

function PART:UpdateMaterial(now)
	self:GetMaterialFromParent()
	for key, val in pairs(self.StorableVars) do
		self["Set" .. key](self, self[key])
	end
end

function PART:OnEvent(event, ...)
	if event == "material_changed" then
		self:UpdateMaterial()
	end
end

function PART:OnParent(parent)
	self:UpdateMaterial()
end

function PART:OnUnParent(parent)
	self.Materialm = nil
	self.updated = false
end

pac.RegisterPart(PART)